{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/users
      ../../common/base.nix
      ../../common/desktop.nix
      ../../common/locale.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix";
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.firewall.enable = false;

  services.openssh.enable = true;
  system.stateVersion = "20.03";

  environment.systemPackages = with pkgs; [
    nano
    git
    wireguard
  ];

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };
  environment.systemPackages = with pkgs; [
    xorg.xf86videovboxvideo
    #xorg.xf86videointel
    #xorg.xf86videoati
    #xorg.xf86videonouveau
  ];
  services.xserver = {
    videoDrivers = [ "virtualbox" ];
    resolutions = [
      { x = 1280; y = 720; }
      { x = 1920; y = 1080; }
      { x = 2560; y = 1440; }
    ];
}

