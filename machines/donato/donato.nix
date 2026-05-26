
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/zsh.nix
    ../../modules/ned-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "donato";

  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };

  virtualisation.oci-containers.containers.caddy = {
    image = "serfriz/caddy-namecheap:2.11";
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
      "--pull=newer"
      "--name=caddy"
      "--cap-add=NET_ADMIN"
    ];
  };

  # Will throw if the dirs don't exist
  systemd.tmpfiles.rules = [
    "d /var/lib/container-data/caddy 0755 root root -"
    "f /var/lib/container-data/caddy/Caddyfile 0644 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
