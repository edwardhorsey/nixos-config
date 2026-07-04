{ config, lib, ... }:
{
  options.sharedVars.nasIp = lib.mkOption {
    type = lib.types.str;
    description = "NAS IP";
    default = "YOUR_NAS_IP_HERE";
  };

  options.sharedVars.localNet = lib.mkOption {
    type = lib.types.str;
    description = "Local network CIDR";
    default = "YOUR_SUBNET_HERE";
  };
}
