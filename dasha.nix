{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
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
    dataDir = "/home/ned";  # default location for new folders
    configDir = "/home/ned/.config/syncthing";
    guiAddress = "0.0.0.0:8384"; 
  };

  networking.hostName = "dasha";

  networking.firewall.allowedTCPPorts = [ 8384 22000 21027 ];

  system.stateVersion = "25.05"; 
}