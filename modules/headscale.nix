{ config, pkgs, lib, unstable, ... }:
with lib;
let
  cfg = config.ripmod.headscale;
  pkgDesc = "ripmod headscale service";
in {
  options = {
    ripmod.headscale = {
      enable = mkEnableOption pkgDesc;
      domain = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "headscale url";
      };
      port = mkOption {
        type = types.int;
        default = 8080;
        description = "headscale port";
      };
      keyfile = mkOption {
        type = types.path;
        description = "headscale private keyfile";
      };
      noisefile = mkOption {
        type = types.path;
        description = "headscale noise keyfile";
      };

    };

  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.headscale
    ]; # services.headscale.package, unstable.headscale use unstable if you have a noise private key file
    networking.firewall = { allowedTCPPorts = [ cfg.port ]; };
    #   environment.persistence = {
    #     "/persist".directories = [ "/var/lib/headscale" ];
    #   };
    services = {
      headscale = {
        enable = true;
        address = "${cfg.domain}";
        port = cfg.port;
        serverUrl = "http://${cfg.domain}:${toString (cfg.port)}";

        user = "headscale";
        group = "headscale";
        logLevel = "info";
        privateKeyFile = cfg.keyfile;
        dns = {
          nameservers = [ "9.9.9.9" ];
          baseDomain = "${cfg.domain}";
          domains = [ "internal" ];
          magicDns = true;
        };
        #aclPolicyFile

        settings = {
          logtail.enabled = false;
          disable_check_updates = true;
          #ip_prefixes = [ "192.168.110.0/24" ];
          ip_prefixes = [ "100.64.0.0/10" "fdef:6567:bd7a::/48" ];
          metrics_listen_addr = "127.0.0.1:9090";
          grpc_allow_insecure = false;
          derp.server.enabled =
            false; # https://tailscale.com/kb/1118/custom-derp-servers/

          noise.private_key_path = cfg.noisefile;
          #tls_cert_path="";
          #tls_key_path=""; # self signed without lets encrypt
        };
      };

    };
  };
}
