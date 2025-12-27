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

  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };

  virtualisation.oci-containers.containers.caddy = {
    image = "serfriz/caddy-namecheap:latest";
    ports = [
      "80:80"
      "443:443"
      "443:443/udp"
    ];
    volumes = [
      "/var/lib/container-data/caddy/Caddyfile:/etc/caddy/Caddyfile"
    ];
    extraOptions = [
      "--name=caddy"
      "--cap-add=NET_ADMIN"
      "--restart=unless-stopped"
    ];
  };

  # Will throw if the dirs don't exist
  systemd.tmpfiles.rules = [
    "f /var/lib/container-data/caddy/Caddyfile 0644 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  networking.hostName = "marcel";

  system.stateVersion = "25.05";
}
