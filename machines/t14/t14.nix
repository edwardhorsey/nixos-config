{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/zsh.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "t14";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  nixpkgs.config.allowUnfree = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.displayManager.cosmic-greeter = { enable = true; };

  services.desktopManager.cosmic = { enable = true; };

  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
  };

  programs.firefox.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.steam.enable = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "Ned";
      user.email = "wned@proton.me";
      core.editor = "vim";
    };
  };
  programs.thunderbird.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    cifs-utils
    duf
    vscode
    plexamp
    obsidian
    nixfmt
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    hostKeys = [{
      comment = "ned-t14";
      path = "etc/ssh/ned-t14_key";
      type = "ed25519";
    }];
  };

  services.tailscale = { enable = true; };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "ned";
    dataDir = "/home/ned/Syncthing";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
