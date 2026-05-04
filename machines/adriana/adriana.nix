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

  age.secrets.adriana-media-credentials.file = ../../secrets/adriana-media-credentials.age;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "adriana";

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/jas" = {
    device = "//192.168.233.240/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.adriana-media-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  fileSystems."/mnt/photos" = {
    device = "//192.168.233.240/photos";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.adriana-media-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ned_ed25519_key";
        comment = "ned@adriana";
      }
    ];
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    openFirewall = true;
  };

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    database.enableVectors = false;
  };

}
