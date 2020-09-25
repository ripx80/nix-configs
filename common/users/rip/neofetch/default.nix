{ pkgs, config, lib, ... }:

with lib;
let
    cfg = config.rip.neofetch;
in {
  options = { rip.neofetch.enable = mkEnableOption "Neofetch"; };
  config = mkIf cfg.enable {
    home = {
        packages = with pkgs; [ neofetch ];
        file.".config/neofetch/config.conf".source = ./config.conf;
    };

  };
}