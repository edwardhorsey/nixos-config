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

  age.secrets.oscar-media-credentials.file = ../secrets/oscar-media-credentials.age;
  age.secrets."oscar-sabnzbd-config" = {
    file = ../secrets/oscar-sabnzbd-config.age;
    owner = "ned";
    mode = "0400";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "oscar";

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    cifs-utils
    duf
  ];

  fileSystems."/mnt/jas" = {
    device = "//192.168.233.240/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.oscar-media-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services.sabnzbd = {
    enable = true;
    user = "ned";
    group = "users";
    openFirewall = true;
    secretFiles = [
      config.age.secrets."oscar-sabnzbd-config".path
    ];
    settings = {
      misc = {
        host = "0.0.0.0";
      };
      servers."eweka" = {
        enable = true;
        host = "news.eweka.nl";
        displayname = "Eweka";
        name = "Eweka";
      };
      servers."bulknews" = {
        enable = true;
        host = "news.bulknews.eu";
        displayname = "Bulknews";
        name = "Bulknews";
      };
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.pinchflat = {
    enable = true;
    user = "ned";
    group = "users";
    openFirewall = true;
    mediaDir = "/mnt/jas/pinchflat/downloads";
    selfhosted = true;
  };

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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # ssh
    allowedUDPPorts = [
      53
      1194
    ]; # dns and openvpn

    extraCommands = ''
      PHYS_IF="ens18"

      VPN_SERVER_RANGES=(
        "79.127.145.0/24"
      )

      LOCAL_NET="192.168.233.0/24"

      # local network traffic
      iptables -A INPUT -s "$LOCAL_NET" -j ACCEPT
      iptables -A OUTPUT -d "$LOCAL_NET" -j ACCEPT

      # traffic to/from ProtonVPN servers
      for range in "''${VPN_SERVER_RANGES[@]}"; do
        iptables -A INPUT -s "$range" -i "$PHYS_IF" -j ACCEPT
        iptables -A OUTPUT -d "$range" -o "$PHYS_IF" -j ACCEPT
      done

      # block all other traffic
      iptables -A INPUT -i "$PHYS_IF" -j REJECT
      ip6tables -A INPUT -i "$PHYS_IF" -j REJECT
      iptables -A OUTPUT -o "$PHYS_IF" -j REJECT
      ip6tables -A OUTPUT -o "$PHYS_IF" -j REJECT
    '';
  };

  system.stateVersion = "25.05";
}
