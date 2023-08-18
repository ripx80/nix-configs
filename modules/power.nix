{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ripmod.power;
  pkgDesc = "enable power reduction";
in {
  options = { ripmod.power = { enable = mkEnableOption pkgDesc; }; };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs;
      [ config.boot.kernelPackages.cpupower ];
    # add powertop for analysis

    powerManagement = {
      enable = true;
      powertop.enable = false;
    };
  };
}
