{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/zsh.nix
    ../../modules/ned-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "dasha";

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

  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
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
      HOME = "/var/lib/uptime-kuma";
    };
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

  virtualisation.oci-containers.containers.netalertx = {
    image = "ghcr.io/jokob-sk/netalertx:26.5";
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
      "--pull=newer"
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

  virtualisation.oci-containers.containers.caddy = {
    image = "serfriz/caddy-namecheap:2.11";
    ports = [
      "80:80"
      "443:443"
      "443:443/udp"
    ];
    volumes = [
      "caddy-data:/data"
      "caddy-config:/config"
      "/var/lib/container-data/caddy:/etc/caddy"
    ];
    extraOptions = [
      "--pull=newer"
      "--name=caddy"
      "--cap-add=NET_ADMIN"
    ];
  };

  # Will throw if the dirs don't exist
  systemd.tmpfiles.rules = [
    "d /var/lib/container-data/caddy 0755 root root -"
    "f /var/lib/container-data/caddy/Caddyfile 0644 root root -"
    "d /var/lib/container-data/baikal/config 0755 root root -"
    "d /var/lib/container-data/baikal/data 0755 root root -"
    "d /var/lib/container-data/gitea/data 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
    3001 # uptime kuma
    8384
    22000
    20211 # netalertx
    20212 # netalertx graphql
  ];

  networking.firewall.allowedUDPPorts = [
    443
    22000
    21027
  ];
}
