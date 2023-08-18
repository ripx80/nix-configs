{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.banner;
  pkgDesc = "agetty banner on login";
  hand = host: label: ''
    \e[0m
    #`````````` ___    ____    ____
    #````______/```\\__//```\\__/____\\
    #``_/```\\_/``:```````````//____ \\
    #`/|``````:``:``..``````/````````\\   host:   ${host}
    #|`|`````::`````::``````\\````````/   system: \s \r (\m)
    #|`|`````:|`````||`````\\`\\______/    label:  ${label}
    #|`|`````||`````||``````|\\``/``|
    #`\\|`````||`````||``````|```/`|`\\
    #``|`````||`````||``````|``/`/_\\`\\
    #``|`___`||`___`||``````|`/``/````\\
    #```\\_-_/``\\_-_/`|`____`|/__/``````\\	Be careful what you do...
    #````````````````_\\_--_/````\\`````/
    #```````````````/____```````````/	    we are watching you!
    #``````````````/`````\\`````````/
    #``````````````\\______\\_______/
  '';

in {
  options = {
    ripmod.banner = {
      enable = mkEnableOption pkgDesc;
      art = mkOption {
        type = types.str;
        default = hand config.networking.hostName config.system.nixos.label;
        description = "ascii art to display";
      };
    };
  };
  config = mkIf cfg.enable {
    services.getty = {
      greetingLine = cfg.art;
      helpLine = lib.mkForce "";
    };
  };
}
