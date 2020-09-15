{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../overlays/users
      ../../overlays/base.nix
      ../../overlays/desktop.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix";
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.firewall.enable = false;

  services.openssh.enable = true;
  system.stateVersion = "20.03";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "de";
    };
    time.timeZone = "Europe/Berlin";
}

