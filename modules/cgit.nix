# {
#   config,
#   lib,
#   pkgs,
#   ...
# }:

# with lib;
# let
#   cfg = config.ripmod.cgit;
#   pkgDesc = "";
# in
# {
#   options = {
#     ripmod.cgit = {
#       enable = mkEnableOption pkgDesc;
#       cert = mkOption {
#         type = types.listOf types.str;
#         default = [ ];
#         description = "ca certificates, system wide";
#       };
#       host = mkOption {
#         type = types.str;
#         default = "";
#         description = "host certificate, create nginx user"; # change to web user if support more than nginx
#       };
#     };
#   };
#   config = mkIf cfg.enable (mkMerge [
#     ({
#       # ca
#       security.pki.certificates = cfg.cert;
#       users.groups.ca = { };
#       users.groups.web = { }; # maybe seperate this in a web module
#     })
#     (mkIf (cfg.host != "") {
#       # host cert, public
#       environment.etc."ssl/cert.pem" = {
#         mode = "444";
#         text = cfg.host + (lib.strings.concatStrings cfg.cert);
#         user = "root";
#         group = "ca";
#       };
#     })
#   ]);
# }
