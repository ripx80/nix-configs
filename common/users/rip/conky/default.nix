{ pkgs, config, lib, ... }:

with lib;
let
    cfg = config.rip.conky;
in {
  options = { rip.conky.enable = mkEnableOption "Conky"; };
  config = mkIf cfg.enable {
    home = {
        packages = with pkgs; [ conky ];
        file.".conkyrc".source = ./conkyrc;
    };
  };
}