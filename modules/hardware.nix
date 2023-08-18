{ hardware, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ripmod.hardware;
  pkgDesc = "hardware modules and installer not detected";
in {
  options = { ripmod.hardware = { enable = mkEnableOption pkgDesc; }; };
  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "usbhid" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    hardware = {
      enableRedistributableFirmware = true;
      enableAllFirmware = true;
      ksm.enable = true;
    };
  };
}
