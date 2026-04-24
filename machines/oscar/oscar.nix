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

  age.secrets."oscar-sabnzbd-config" = {
    file = ../../secrets/oscar-sabnzbd-config.age;
    owner = "ned";
    mode = "0400";
  };

  age.secrets."oscar-slskd-config" = {
    file = ../../secrets/oscar-slskd-config.age;
    owner = "ned";
    mode = "0400";
  };

  age.secrets."oscar-wireguard-config" = {
    file = ../../secrets/oscar-wireguard-config.age;
    mode = "0400";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "oscar";

  environment.systemPackages = with pkgs; [
    beets
    cifs-utils
  ];

  fileSystems."/mnt/jas" = {
    device = "192.168.233.240:/mnt/JAS/media/media";
    fsType = "nfs";
  };

  fileSystems."/mnt/music" = {
    device = "192.168.233.240:/mnt/JAS/docs/music";
    fsType = "nfs";
  };

  users.groups.nas-users = {
    gid = 3000;
  };

  users.users.ned.extraGroups = lib.mkAfter [ "nas-users" ];

  nixpkgs.config.allowUnfree = true;

  services.sabnzbd = {
    enable = true;
    user = "ned";
    group = "nas-users";
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

  services.slskd = {
    enable = true;
    user = "ned";
    group = "nas-users";
    domain = null;
    environmentFile = config.age.secrets."oscar-slskd-config".path;
    settings = {
      directories = {
        downloads = "/mnt/jas/slskd/downloads";
        incomplete = "/mnt/jas/slskd/incomplete";
      };
      shares = {
        directories = [ "/mnt/jas/slskd/downloads" ];
      };
    };
  };

  systemd.services.slskd = {
    unitConfig = {
      RequiresMountsFor = [ "/mnt/jas" ];
    };
    serviceConfig = {
      ReadOnlyPaths = lib.mkForce [ ];
      ReadWritePaths = [ "/mnt/jas/slskd" "/mnt/jas/slskd/downloads" "/mnt/jas/slskd/incomplete" ];
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.pinchflat = {
    enable = true;
    user = "ned";
    group = "nas-users";
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

  networking.wg-quick.interfaces.proton = {
    configFile = config.age.secrets."oscar-wireguard-config".path;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # ssh
    allowedUDPPorts = [ 53 ]; # dns

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

}
