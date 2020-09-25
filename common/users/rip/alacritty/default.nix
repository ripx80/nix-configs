{ pkgs, config, lib, ... }:

with lib;
let
    cfg = config.rip.alacritty;
in {
  options = { rip.alacritty.enable = mkEnableOption "Alacritty"; };
  config = mkIf cfg.enable {
    home = {
        packages = with pkgs; [ alacritty ];
        file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
    };
  };
}
