{ hardware, config, pkgs, ... }:

{

#   imports = [
#     <home-manager/nixos>
#   ];
  environment.systemPackages = with pkgs; [
    google-chrome
    killall
    file
    #xorg
    #xorg.xorgserver
    # input
    #xorg.xf86inputevdev
    #xorg.xf86inputsynaptics
    xorg.xf86inputlibinput
    # drivers
    #xorg.xf86videointel
    #xorg.xf86videoati
    #xorg.xf86videonouveau
    xorg.xf86videovboxvideo
    # window manager
    openbox
    hsetroot
    xcompmgr
    zathura
    neofetch
    hack-font
    alacritty
  ];
  #DRI acceleration
  #hardware.opengl.enable = true;
  #hardware.opengl.driSupport = true;

#   rip = {
#     openbox.enable = true;
#     gui.enable = true;
#   };

  virtualisation.docker.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    autorun = false; # Important!

    exportConfiguration = true; # Important!

    layout = "de-latin-nodeadkeys";
    # xkbOptions = "eurosign:e";

    videoDrivers = [ "vboxvideo" ];
    resolutions = [
      { x = 1280; y = 720; }
      { x = 1920; y = 1080; }
      { x = 2560; y = 1440; }
    ];

    # Enable touchpad support.
    libinput.enable = true;

  };
}