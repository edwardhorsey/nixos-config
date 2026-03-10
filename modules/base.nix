{ config, lib, pkgs, ... }:

{
  # Common settings shared by all hosts
  time.timeZone = "Europe/London";

  services.openssh.enable = true;

  system.stateVersion = "25.05";
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Small, stable set of base CLI tools
  environment.systemPackages = with pkgs; [
    vim
    wget
    duf
    htop
    tree
    git
  ];

  programs.mtr.enable = true;
}
