{ hardware, config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # input
    #xorg.xf86inputevdev
    #xorg.xf86inputsynaptics
    xorg.xf86inputlibinput
  ];


hardware = {
    # Audio
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      daemon.config = {
        flat-volumes = "no";
      };
    };

  #DRI acceleration
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Bluetooth
    # https://nixos.wiki/wiki/Bluetooth
    bluetooth = {
      enable = true;
      # For Bose QC 35
      config = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  virtualisation.docker.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    autorun = false;
    exportConfiguration = true;
    layout = "de";
    # xkbOptions = "eurosign:e";
    # Enable touchpad support.
    libinput.enable = true;
  };
}