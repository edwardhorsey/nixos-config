{ config, lib, pkgs, ... }:

{
  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIve+Rr2KSDKwFwf1R4mzCTJGbbirXCOpztbOJf1T0H"
    ];
  };
}
