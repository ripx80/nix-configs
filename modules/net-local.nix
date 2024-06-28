{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.net-local;
  pkgDesc = "enable a static local net configuration for testing or access";
in
{
  options = {
    ripmod.net-local = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {
    networking = {
      useDHCP = lib.mkForce false;
      defaultGateway = "192.168.1.1";
      nameservers = [ "9.9.9.9" ];
      interfaces.enp1s0 = {
        ipv4.addresses = [
          {
            address = "192.168.1.80";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
