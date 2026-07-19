{ config, lib, ... }:
{
  options.sharedVars.nasIp = lib.mkOption {
    type = lib.types.str;
    description = "NAS IP";
    default = "YOUR_NAS_IP_HERE";
  };

  options.sharedVars.localNets = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Local network CIDRs";
    default = [ "YOUR_SUBNET_HERE" ];
  };
}
