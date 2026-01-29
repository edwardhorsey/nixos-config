{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/zsh.nix
    ../modules/ned-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "dasha";

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    duf
  ];

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ned_ed25519_key";
        comment = "ned@dasha";
      }
    ];
  };

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
    };
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    openFirewall = true;
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
    path = [ pkgs.zip pkgs.coreutils pkgs.findutils ];
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
    image = "gitea/gitea:latest";
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
  };

  virtualisation.oci-containers.containers.netalertx = {
    image = "ghcr.io/jokob-sk/netalertx:latest";
    autoStart = true;
    volumes = [
      "netalertx_data:/data"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
      PUID = "20211";
      PGID = "20211";
      LISTEN_ADDR = "0.0.0.0";
      PORT = "20211";
      GRAPHQL_PORT = "20212";
      ALWAYS_FRESH_INSTALL = "false";
      NETALERTX_DEBUG = "0";
    };
    extraOptions = [
      "--network=host"
      "--cap-drop=ALL"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--cap-add=NET_BIND_SERVICE"
      "--cap-add=CHOWN"
      "--cap-add=SETUID"
      "--cap-add=SETGID"
      "--read-only"
    ];
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
    22000
    20211 # netalertx
    20212 # netalertx graphql
  ];

  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  system.stateVersion = "25.05";
}
