{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.boot;
  pkgDesc = "rip boot options";
in {
  options = { ripmod.boot = { enable = mkEnableOption pkgDesc; }; };
  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [ "btrfs" "ntfs" "vfat" ];
      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          devices = [ "nodev" ];
          efiSupport = true;
          splashImage = ./splash/splash-bar.jpg;
        };
      };
    };
  };
}
