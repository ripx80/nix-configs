{ pkgs, config, lib, ... }:

with lib;
let cfg = config.ripmod.tiny;
in {
  options = { ripmod.tiny.enable = mkEnableOption "Tiny"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ tiny ];
      file.".config/tiny/config.yml".source = ./config.yml;
    };
  };
}
