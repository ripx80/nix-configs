{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.nft.ingress-ddos;
  pkgDesc = ''
    nftables ingress ddos protection. uses nft tables: "netdev filter ingress|ingress_filter".
    be careful, no flush happens here, if you start this multiple times it will stacked.
  '';
in
{
  options = {
    ripmod.nft.ingress-ddos = {
      enable = mkEnableOption "enable systemd oneshot service to enable nft ingress ddos protection";

      services = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          systemd services that must be present.
          this is important for dynamic interfaces like wireguard wg0.
        '';
        example = [ "wireguard-wg0.service" ];
      };
      interfaces = mkOption {
        type = types.listOf types.str;
        description = "list of interfaces that should be protected";
        example = [
          "enp10s0"
          "wg0"
        ];
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      systemd.services.nftables-ingress = {
        description = "ingress for dynamic interfaces";
        # make sure dynamic interfaces are up
        after = [ "network-pre.target" ] ++ cfg.services;
        wants = [ "network-pre.target" ] ++ cfg.services;
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = with pkgs; ''
          #!${stdenv.shell}

          ${nftables}/bin/nft -f - << EOF
          table netdev filter {
              chain ingress {
                  type filter hook ingress devices = {${lib.strings.concatStringsSep "," cfg.interfaces}} priority -500
                  jump ingress_filter
              }

              chain ingress_filter {
                  # Basic filter chain, devices can be configued to jump here
                  ip frag-off & 0x1fff != 0 counter drop comment "drop all fragments"
                  tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg counter drop comment "drop xmas packets"
                  tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 counter drop comment "drop null packets"
                  tcp flags syn tcp option maxseg size 1-535 counter drop comment "drop uncommon mss values"
                  tcp flags & (fin|syn) == (fin|syn) counter drop comment "drop fin and syn at the same time"
                  tcp flags & (syn|rst) == (syn|rst) counter drop comment "drop rst and syn at the same time"
              }
          }
          EOF
        '';
      };
    })
  ];
}
