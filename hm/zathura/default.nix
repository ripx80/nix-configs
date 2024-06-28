{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.zathura;
in
{
  options = {
    ripmod.zathura.enable = mkEnableOption "Zathura";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ zathura ];
      file.".config/zathura/zathurarc".source = ./zathurarc;
    };
  };
}
