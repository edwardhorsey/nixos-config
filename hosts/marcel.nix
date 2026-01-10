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
    ../modules/ned-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "marcel";

  time.timeZone = "Europe/London";

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
      "caddy-data:/data"
      "caddy-config:/config"
      "/var/lib/container-data/caddy:/etc/caddy"
    ];
    extraOptions = [
      "--name=caddy"
      "--cap-add=NET_ADMIN"
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

  system.stateVersion = "25.05";
}
