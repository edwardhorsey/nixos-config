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

  system.stateVersion = "25.05"; 
}