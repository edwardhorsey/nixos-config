{ config, lib, ... }:
{
  options.sharedVars.nasIp = lib.mkOption {
    type = lib.types.str;
    description = "NAS IP";
    default = "YOUR_NAS_IP_HERE";
  };
}
