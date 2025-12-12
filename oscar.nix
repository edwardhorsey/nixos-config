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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  networking.hostName = "oscarnix";

  system.stateVersion = "25.05";
}
