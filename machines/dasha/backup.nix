{
  config,
  lib,
  pkgs,
  ...
}:

let
  mountPoint = "/mnt/backups/dasha";
  repository = "${mountPoint}/restic";
  stagingDirectory = "/var/lib/dasha-backup-staging";
  restoreDirectory = "/var/lib/dasha-restic-restore-test";
  resticPasswordFile = config.age.secrets."dasha-restic-password".path;

  systemctl = lib.getExe' config.systemd.package "systemctl";
  rsync = lib.getExe pkgs.rsync;
  sqlite = lib.getExe pkgs.sqlite;
  restic = lib.getExe pkgs.restic;
  jq = lib.getExe pkgs.jq;

  prepareBackup = pkgs.writeShellScript "prepare-dasha-backup" ''
    set -euo pipefail

    active_units=()

    restart_active_units() {
      local restart_status=0

      set +e
      for ((i = ''${#active_units[@]} - 1; i >= 0; i--)); do
        if ! ${systemctl} start "''${active_units[$i]}"; then
          echo "Failed to restart ''${active_units[$i]}" >&2
          restart_status=1
        fi
      done
      active_units=()
      set -e

      return "$restart_status"
    }

    stop_if_active() {
      local unit="$1"

      if ${systemctl} is-active --quiet "$unit"; then
        active_units+=("$unit")
        ${systemctl} stop "$unit"
      fi
    }

    copy_tree() {
      local source="$1"
      local destination="$2"

      if [[ ! -d "$source" ]]; then
        echo "Required backup source does not exist: $source" >&2
        return 1
      fi

      ${pkgs.coreutils}/bin/mkdir -p "$destination"
      ${rsync} -aHAX --numeric-ids --delete "$source/" "$destination/"
    }

    snapshot_service() {
      local unit="$1"
      local source="$2"
      local destination="$3"

      active_units=()
      stop_if_active "$unit"
      copy_tree "$source" "$destination"
      restart_active_units
    }

    trap restart_active_units EXIT

    ${pkgs.coreutils}/bin/rm -rf -- "${stagingDirectory}"/*
    ${pkgs.coreutils}/bin/mkdir -p "${stagingDirectory}/manifest"

    snapshot_service \
      syncthing.service \
      /home/ned/.config/syncthing \
      "${stagingDirectory}/syncthing"

    snapshot_service \
      uptime-kuma.service \
      /var/lib/uptime-kuma \
      "${stagingDirectory}/uptime-kuma"

    snapshot_service \
      beszel-hub.service \
      /var/lib/beszel-hub \
      "${stagingDirectory}/beszel-hub"

    active_units=()
    stop_if_active freshrss-updater.timer
    ${systemctl} stop freshrss-updater.service
    stop_if_active phpfpm-freshrss.service
    copy_tree /var/lib/freshrss "${stagingDirectory}/freshrss"
    restart_active_units

    snapshot_service \
      podman-baikal.service \
      /var/lib/container-data/baikal \
      "${stagingDirectory}/baikal"

    snapshot_service \
      podman-gitea.service \
      /var/lib/container-data/gitea \
      "${stagingDirectory}/gitea"

    {
      echo "created=$(${pkgs.coreutils}/bin/date --iso-8601=seconds)"
      ${pkgs.podman}/bin/podman inspect --format 'baikal={{.ImageName}} {{.Image}}' baikal || true
      ${pkgs.podman}/bin/podman inspect --format 'gitea={{.ImageName}} {{.Image}}' gitea || true
    } >"${stagingDirectory}/manifest/versions.txt"

    trap - EXIT
  '';
in
{
  options.sharedVars.nasIp = lib.mkOption {
    type = lib.types.str;
    description = "NAS IP address used for Dasha backups";
  };

  config = {
    age.secrets."dasha-restic-password" = {
      file = ../../secrets/dasha-restic-password.age;
      mode = "0400";
    };

    boot.supportedFilesystems = [ "nfs" ];

    fileSystems.${mountPoint} = {
      device = "${config.sharedVars.nasIp}:/mnt/JAS/backups/dasha";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "_netdev"
        "noexec"
        "nodev"
        "nosuid"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=30s"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${stagingDirectory} 0700 root root -"
    ];

    services.restic.backups = {
      dasha = {
        inherit repository;
        passwordFile = resticPasswordFile;
        initialize = true;
        paths = [ stagingDirectory ];
        backupPrepareCommand = "${prepareBackup}";
        backupCleanupCommand = ''
          ${pkgs.coreutils}/bin/rm -rf -- "${stagingDirectory}"/*
        '';
        extraBackupArgs = [
          "--retry-lock=30m"
          "--tag=dasha"
        ];
        pruneOpts = [
          "--retry-lock=30m"
          "--keep-daily 14"
          "--keep-weekly 8"
          "--keep-monthly 12"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };

      dasha-check = {
        inherit repository;
        passwordFile = resticPasswordFile;
        paths = [ ];
        runCheck = true;
        checkOpts = [
          "--retry-lock=30m"
          "--read-data-subset=5%"
        ];
        createWrapper = false;
        timerConfig = {
          OnCalendar = "Sun *-*-* 04:00:00";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
    };

    systemd.services = {
      restic-backups-dasha = {
        unitConfig.RequiresMountsFor = [ mountPoint ];
        serviceConfig.TimeoutStartSec = "2h";
      };

      restic-backups-dasha-check = {
        unitConfig.RequiresMountsFor = [ mountPoint ];
        serviceConfig.TimeoutStartSec = "2h";
      };

      dasha-backup-restore-test = {
        description = "Restore and validate the latest Dasha backup";
        unitConfig.RequiresMountsFor = [ mountPoint ];
        environment.RESTIC_PASSWORD_FILE = resticPasswordFile;
        path = [
          pkgs.coreutils
          pkgs.jq
          pkgs.sqlite
        ];
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "dasha-restic-restore-test";
          StateDirectoryMode = "0700";
          TimeoutStartSec = "2h";
        };
        script = ''
          set -euo pipefail
          shopt -s nullglob

          test "${restoreDirectory}" = "/var/lib/dasha-restic-restore-test"
          ${pkgs.coreutils}/bin/rm -rf -- "${restoreDirectory}/restore"
          trap '${pkgs.coreutils}/bin/rm -rf -- "${restoreDirectory}/restore"' EXIT

          snapshot_json="$(${restic} -r "${repository}" snapshots --retry-lock=30m --json --tag dasha)"
          snapshot_id="$(printf '%s' "$snapshot_json" | ${jq} -er 'sort_by(.time) | last | .id')"
          snapshot_time="$(printf '%s' "$snapshot_json" | ${jq} -er 'sort_by(.time) | last | .time')"
          snapshot_age=$(($(${pkgs.coreutils}/bin/date +%s) - $(${pkgs.coreutils}/bin/date -d "$snapshot_time" +%s)))

          if (( snapshot_age > 172800 )); then
            echo "Latest Dasha backup is more than 48 hours old: $snapshot_time" >&2
            exit 1
          fi

          ${restic} -r "${repository}" restore --retry-lock=30m "$snapshot_id" --target "${restoreDirectory}/restore"

          stage="${restoreDirectory}/restore${stagingDirectory}"

          check_db() {
            local db="$1"
            local result

            if [[ ! -f "$db" ]]; then
              echo "Required database is missing from restored backup: $db" >&2
              return 1
            fi

            result="$(${sqlite} -readonly "$db" 'PRAGMA integrity_check;')"
            if [[ "$result" != "ok" ]]; then
              echo "SQLite integrity check failed: $db" >&2
              return 1
            fi
          }

          check_db "$stage/syncthing/index-v2/main.db"
          check_db "$stage/uptime-kuma/kuma.db"
          check_db "$stage/beszel-hub/beszel_data/data.db"
          check_db "$stage/baikal/data/db/db.sqlite"
          check_db "$stage/gitea/data/gitea/gitea.db"

          syncthing_folder_dbs=("$stage/syncthing/index-v2"/folder.*.db)
          for db in "''${syncthing_folder_dbs[@]}"; do
            check_db "$db"
          done

          beszel_optional_dbs=("$stage/beszel-hub/beszel_data/auxiliary.db")
          for db in "''${beszel_optional_dbs[@]}"; do
            if [[ -f "$db" ]]; then
              check_db "$db"
            fi
          done

          freshrss_dbs=("$stage/freshrss/users"/*/db.sqlite)
          if (( ''${#freshrss_dbs[@]} == 0 )); then
            echo "No FreshRSS databases were restored" >&2
            exit 1
          fi
          for db in "''${freshrss_dbs[@]}"; do
            check_db "$db"
          done

          test -s "$stage/syncthing/config.xml"
          test -s "$stage/syncthing/cert.pem"
          test -s "$stage/syncthing/key.pem"
          test -s "$stage/gitea/data/gitea/conf/app.ini"
          test -s "$stage/manifest/versions.txt"

          echo "Latest Dasha backup restored and validated successfully"
        '';
      };
    };

    systemd.timers.dasha-backup-restore-test = {
      description = "Monthly restore test for Dasha backups";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-01 05:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
