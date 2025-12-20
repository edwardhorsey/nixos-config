# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/zsh.nix
  ];

  age.secrets.nas-credentials.file = ./secrets/nas-credentials.age;
  age.secrets.nas-photos-credentials.file = ./secrets/nas-photos-credentials.age;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/London";

  fileSystems."/mnt/jas" = {
    device = "//192.168.233.240/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.nas-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  fileSystems."/mnt/photos" = {
    device = "//192.168.233.200/ned-store";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.nas-photos-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable sudo for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    cifs-utils
    git
  ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ned_ed25519_key";
        comment = "ned@adriana";
      }
    ];
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    openFirewall = true;
  };

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 13378 ];

  networking.hostName = "adriana";

  system.stateVersion = "25.05";
}
