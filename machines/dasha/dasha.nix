{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./local.nix
    ../../modules/base.nix
    ../../modules/zsh.nix
    ../../modules/ned-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "dasha";

  age.secrets."dasha-searxng-secret" = {
    file = ../../secrets/dasha-searxng-secret.age;
    owner = "searx";
    mode = "0400";
  };

  age.identityPaths = [
    "/etc/ssh/ssh_host_ned_ed25519_key"
  ];

  services.syncthing = {
    enable = true;
    user = "ned";
    dataDir = "/home/ned"; # default location for new folders
    configDir = "/home/ned/.config/syncthing";
    guiAddress = "0.0.0.0:8384";
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
      HOME = "/var/lib/uptime-kuma";
    };
  };

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
  };

  virtualisation.oci-containers.containers.baikal = {
    image = "ckulka/baikal:nginx";
    ports = [ "8002:80" ];
    volumes = [
      "/var/lib/container-data/baikal/config:/var/www/baikal/config"
      "/var/lib/container-data/baikal/data:/var/www/baikal/Specific"
    ];
    extraOptions = [ "--name=baikal" ];
  };

  systemd.services.baikal-backup = {
    description = "Backup Baikal config and data to /home/ned/baikal-backups";
    serviceConfig = {
      Type = "oneshot";
      User = "ned";
    };
    path = [
      pkgs.zip
      pkgs.coreutils
      pkgs.findutils
    ];
    script = ''
      set -euo pipefail
      BACKUP_DIR="/home/ned/baikal-backups"
      CONFIG_DIR="/var/lib/container-data/baikal/config"
      DATA_DIR="/var/lib/container-data/baikal/data"
      DATE=$(date +%Y-%m-%d-%H%M%S)
      mkdir -p "''$BACKUP_DIR"
      ${pkgs.zip}/bin/zip -r "''$BACKUP_DIR/baikal-backup-''$DATE.zip" "''$CONFIG_DIR" "''$DATA_DIR"
      find "''$BACKUP_DIR" -name "baikal-backup-*.zip" -mtime +21 -delete
    '';
  };

  systemd.timers.baikal-backup = {
    description = "Run Baikal backup daily at 2am";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 21:00:00";
      Persistent = true;
    };
  };

  virtualisation.oci-containers.containers.gitea = {
    image = "gitea/gitea:1.26";
    ports = [
      "3000:3000"
      "222:22"
    ];
    volumes = [
      "/var/lib/container-data/gitea/data:/data"
      "/etc/timezone:/etc/timezone:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
      USER_UID = "1000";
      USER_GID = "1000";
    };
    extraOptions = [ "--pull=newer" ];
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings.server = {
      bind_address = "0.0.0.0";
      port = 8888;
      secret_key = config.age.secrets."dasha-searxng-secret".path;
    };
    settings.engines = [
      {
        name = "bing";
        disabled = false;
      }
      {
        name = "qwant";
        disabled = false;
      }
      {
        name = "startpage";
        disabled = false;
      }
      {
        name = "mojeek";
        disabled = false;
      }
    ];
    settings.search = {
      formats = [
        "html"
        "json"
      ];
    };
    limiterSettings = {
      botdetection = {
        ip_limit = {
          filter_link_local = false;
          link_token = false;
        };
        ip_lists = {
          pass_ip = [ config.sharedVars.localNet ];
        };
      };
    };
  };

  # Will throw if the dirs don't exist
  systemd.tmpfiles.rules = [
    "d /var/lib/container-data/baikal/config 0755 root root -"
    "d /var/lib/container-data/baikal/data 0755 root root -"
    "d /var/lib/container-data/gitea/data 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    3001 # uptime kuma
    8384
    8090 # beszel hub
    22000
    8888 # searxng
  ];

  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];
}
