# todo: test
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ripmod.smart;
  pkgDesc = "enable smart disk service";
in {
  options = { ripmod.smart = { enable = mkEnableOption pkgDesc; }; };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ smartmontools ];
    services.smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        x11.enable = if config.services.xserver.enable then true else false;
        wall.enable = true; # send wall notifications to all users
      };
      #devices = [ { device = "/dev/nvme0n1"; }]; # only for special devices
    };
  };
}
