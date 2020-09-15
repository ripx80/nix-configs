{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../overlays/users/
      ../../overlays/base/
      ../../overlays/desktop/
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix";
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.firewall.enable = false;

  services.openssh.enable = true;
  system.stateVersion = "20.03";
}

