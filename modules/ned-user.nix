{ config, lib, pkgs, ... }:

{
  users.users.ned = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFh7nwriC70aWl2GmZoTXxFSSZ4IU5LUF+tq8cC7rqu+"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ2O5L9O7sqe2wDTCXFtEQqNtopfkgj0Yb92Q8a3yaW"
    ];
  };
}
