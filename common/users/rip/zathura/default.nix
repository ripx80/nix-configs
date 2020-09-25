{ pkgs, config, lib, ... }:

with lib;
let
    cfg = config.rip.zathura;
in {
  options = { rip.zathura.enable = mkEnableOption "Zathura"; };
  config = mkIf cfg.enable {
    home = {
        packages = with pkgs; [ zathura ];
        file.".config/zathura/zathurarc".source = ./zathurarc;
    };
  };
}