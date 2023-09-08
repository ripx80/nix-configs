# check after restruct
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ripmod.unbound;
  pkgDesc = "ripmod unbound service";

in {
  options = {
    ripmod.unbound = {
      enable = mkEnableOption pkgDesc;

      private-address = mkOption {
        type = types.listOf types.str;
        description = "additional interface then localhost";
      };

      interface = mkOption {
        type = types.listOf types.str;
        default = [ "0.0.0.0" ];
        description = "additional interface then localhost";
      };

      access-control = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "additional access control then localhost";
      };

      dns-data = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "add additional dns data here";
      };

      include = mkOption {
        type = types.str;
        default = "";
        description = "add additional includes here";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unbound ];
    services.unbound = {
      enable = true;
      user = "unbound"; # default
      group = "unbound"; # default
      enableRootTrustAnchor = true; # default
      #https://github.com/NixOS/nixpkgs/blob/0152de25d49dc16883b65f3e29cfea8d32f68956/nixos/modules/services/networking/unbound.nix#L164
      settings = {
        server = {
          interface = [ "127.0.0.1" "::1" ] ++ cfg.interface; # default
          num-threads = 1;
          verbosity = 1;
          #root-hints= root.hints;
          #trust-anchor-file set by default
          #do-daemonize = false; # default in unbound.nix

          max-udp-size = 3072;
          access-control = [ "127.0.0.1/8 allow" "::1/128 allow" ]
            ++ cfg.access-control;

          private-address = cfg.private-address;

          hide-identity = true;
          hide-version = true;
          hide-trustanchor = true;

          harden-glue = true;
          harden-dnssec-stripped = true;
          harden-referral-path = true;

          unwanted-reply-threshold = 10000000;

          val-log-level = 1;
          use-syslog = true; # queries will be shipped
          log-queries = false;
          #logfile = "/var/lib/unbound/unbound.log";

          cache-min-ttl = 1800;
          cache-max-ttl = 14400;
          prefetch = true;
          prefetch-key = true;

          tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";

          # Send minimum amount of information to upstream servers
          qname-minimisation = true;
          # better performance mutliple bind to one port
          so-reuseport = true;
          include = cfg.include;
        };
        server = { # maybe a option?
          domain-insecure = "fn";
          private-domain = "fn";
          local-zone = "fn. static";
          local-data = cfg.dns-data;
        };
        forward-zone = [{
          name = ".";
          #quad9
          forward-addr = [
            "9.9.9.9@853"
            "149.112.112.112@853"
            #"2620:fe::fe"
            #"2620:fe::9"
          ];
          forward-ssl-upstream = true;
          #forward-addr = [
          #    "1.1.1.1@853#cloudflare-dns.com"
          #    "1.0.0.1@853#cloudflare-dns.com"
          #];
        }];
      };
    };
  };
}
