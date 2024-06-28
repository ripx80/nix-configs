{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.keybase;
in
{
  options.ripmod.keybase = {
    enable = mkEnableOption "Enable keybase/kbfs support";
    gui = mkEnableOption "Enable keybase gui installation";
  };

  config = mkIf cfg.enable {
    services.keybase.enable = true; # disable only for network analysis
    services.kbfs.enable = true; # disable only for network analysis

    home.packages = if cfg.gui then [ pkgs.keybase-gui ] else [ pkgs.keybase ];
  };
}
