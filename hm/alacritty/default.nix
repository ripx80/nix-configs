{ pkgs, config, lib, ... }:

with lib;
let cfg = config.ripmod.alacritty;
in {
  options = { ripmod.alacritty.enable = mkEnableOption "Alacritty"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ alacritty ];
      file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
    };
  };
}
