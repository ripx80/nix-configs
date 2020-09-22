{ hardware, config, pkgs, ... }:

{

#   imports = [
#     <home-manager/nixos>
#   ];
  environment.systemPackages = with pkgs; [
    google-chrome
    killall
    file
    openbox
    hsetroot
    xcompmgr
    zathura

    spotify

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


    hack-font
    alacritty
    conky
    rxvt_unicode
    vscode
    pavucontrol
  ];

hardware = {
# Audio
    # Use `pactl set-sink-volume 0 +10%` to increase volume.
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      daemon.config = {
        flat-volumes = "no";
      };
    };
  # spotify: to sync local tracks from your filesystem with mobile devices in the same network
  # networking.firewall.allowedTCPPorts = [ 57621 ];
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

    layout = "de";
    # xkbOptions = "eurosign:e";

    videoDrivers = [ "virtualbox" ];
    resolutions = [
      { x = 1280; y = 720; }
      { x = 1920; y = 1080; }
      { x = 2560; y = 1440; }
    ];

    # Enable touchpad support.
    libinput.enable = true;

  };
}