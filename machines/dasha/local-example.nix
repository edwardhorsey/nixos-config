{ config, lib, ... }:
{
  options.sharedVars.localNet = lib.mkOption {
    type = lib.types.str;
    description = "Local network CIDR";
    default = "YOUR_SUBNET_HERE";
  };
}
