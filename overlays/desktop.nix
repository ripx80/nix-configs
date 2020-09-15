{ config, pkgs, ... }:

{

#   imports = [
#     <home-manager/nixos>
#   ];
  environment.systemPackages = with pkgs; [
    google-chrome
    killall
    file
    openbox
  ];

  rip = {
    openbox.enable = true;
    gui.enable = true;
  };

  virtualisation.docker.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];


}