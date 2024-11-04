# define virt_out = "eth0"
# ${builtins.readFile (nix-configs + /modules/nft/br0-virt.nft)}

{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ripmod.virt.network;
  pkgDesc = "private network for virt hosts or containers";
in
{
  options = {
    ripmod.virt.network = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {
    # container/vm bridge
    # bridge link show br0
    networking = {
      bridges.br0.interfaces = [ ];
      interfaces."br0".useDHCP = false;

      interfaces.br0.ipv4.addresses = [
        {
          address = "192.168.178.1";
          prefixLength = 24;
        }
      ];
    };
  };
}
