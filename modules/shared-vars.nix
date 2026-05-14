{ lib, ... }:

{
  options.sharedVars = {
    nasIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.233.240";
      description = "NAS IP";
    };

    localNet = lib.mkOption {
      type = lib.types.str;
      default = "192.168.233.0/24";
      description = "Local network CIDR";
    };
  };
}
