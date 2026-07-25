{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./local.nix
    ../../modules/base.nix
    ../../modules/zsh.nix
    ../../modules/ned-user.nix
  ];

  age.secrets.adriana-media-credentials.file = ../../secrets/adriana-media-credentials.age;
  age.identityPaths = [
    "/etc/ssh/ssh_host_ned_ed25519_key"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "adriana";

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/jas" = {
    device = "//${config.sharedVars.nasIp}/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.adriana-media-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
    ];
  };

  fileSystems."/mnt/photos" = {
    device = "//${config.sharedVars.nasIp}/photos";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.adriana-media-credentials.path}"
      "uid=1000"
      "gid=100"
      "vers=3.0"
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
  };

}
