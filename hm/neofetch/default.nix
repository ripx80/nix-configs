{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.neofetch;
in
{
  options = {
    ripmod.neofetch.enable = mkEnableOption "Neofetch";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ neofetch ];
      file.".config/neofetch/config.conf".source = ./config.conf;
    };
  };
}
