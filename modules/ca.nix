{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.ca;
  pkgDesc = "ca and host ca file";
in
{
  options = {
    ripmod.ca = {
      enable = mkEnableOption pkgDesc;
      cert = mkOption {
        type = types.str;
        description = "ca certificate, system wide";
      };
      host = mkOption {
        type = types.str;
        default = "";
        description = "host certificate, create nginx user"; # change to web user if support more than nginx
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    ({
      # ca
      security.pki.certificates = [ cfg.cert ];
      users.groups.ca = { };
      users.groups.web = { }; # maybe seperate this in a web module
    })
    (mkIf (cfg.host != "") {
      # host cert, public
      environment.etc."ssl/cert.pem" = {
        mode = "444";
        text = cfg.host + cfg.cert;
        user = "root";
        group = "ca";
      };
    })
  ]);
}
