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
        comment = "ned nixos oscar";
      }
    ];
  };

  services.openvpn.servers.proton = {
    autoStart = true;
    updateResolvConf = true;
    config = ''
      config /root/nixos/openvpn/proton.ovpn
      auth-user-pass /root/nixos/openvpn/proton-auth.txt
    '';
  };

  networking.hostName = "oscar";

  system.stateVersion = "25.05";
}
