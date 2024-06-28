# add dnscrypt-proxy2 and dnsmasq. set nameserver to localhost
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.dnscrypt;
  pkgDesc = "dnscrypt localhost";
in
{
  options = {
    ripmod.dnscrypt = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {
    networking.nameservers = [ "127.0.0.1:43" ];
    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ "127.0.0.1:43" ];
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md"
          ];
          cache_file = "public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 72;
        };
        server_names = [ "quad9-dnscrypt-ip4-filter-pri" ];
      };
    };
    services.dnsmasq.enable = true;
    services.dnsmasq.settings.servers = [ "127.0.0.1#43" ];
  };
}
