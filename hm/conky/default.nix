{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.conky;
in
{
  options = {
    ripmod.conky.enable = mkEnableOption "Conky";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ conky ];
      file.".conkyrc".source = ./conkyrc;
    };
  };
}
