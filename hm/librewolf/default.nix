{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.librewolf;
in
{
  options = {
    ripmod.librewolf.enable = mkEnableOption "LibreWolf";
  };
  config = mkIf cfg.enable {
    # settings: https://librewolf.net/docs/settings/
    programs.librewolf = {
      enable = true;

      settings = {
        # Enable WebGL, cookies and history
        #"webgl.disabled" = false;
        #"privacy.resistFingerprinting" = false;
        #"privacy.clearOnShutdown.history" = false;
        #"privacy.clearOnShutdown.cookies" = false;
        #"network.cookie.lifetimePolicy" = 0;
      };
    };
    # packages = with pkgs; [ librewolf ];
  };
}
