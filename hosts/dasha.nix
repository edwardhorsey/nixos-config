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
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/London";

  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable sudo for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

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

  virtualisation.oci-containers.containers.baikal = {
    image = "ckulka/baikal:nginx";
    ports = [ "8002:80" ];
    volumes = [
      "/var/lib/container-data/baikal/config:/var/www/baikal/config"
      "/var/lib/container-data/baikal/data:/var/www/baikal/Specific"
    ];
    extraOptions = [ "--name=baikal" ];
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
  ];

  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  networking.hostName = "dasha";

  system.stateVersion = "25.05";
}
