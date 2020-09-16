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
    #xorg.xf86inputlibinput
    # drivers
    #xorg.xf86videointel
    #xorg.xf86videoati
    #xorg.xf86videonouveau
    # window manager
    openbox
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

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
}