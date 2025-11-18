# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/mnt/jas" = {
    device = "//192.168.233.240/media";
    fsType = "cifs";
    options = [
      "username=username"
      "password=password"
      "uid=0"
      "gid=0"
      "vers=3.0"
    ];
  }; 

  networking.firewall.allowedTCPPorts = [ 13378 ];

  users.users.ned = {
    isNormalUser = true;
    password = "ned";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    cifs-utils
  ];

  services.openssh.enable = true;

  services.audiobookshelf = {
    enable = true;
    user = "ned";
    host = "0.0.0.0";
    port = 13378;
    openFirewall = true;
  };

  system.stateVersion = "25.05"; 
}