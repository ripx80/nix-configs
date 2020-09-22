{ config, pkgs, ... }:

{
  imports =
  [
      ./neofetch.nix
  ];
  home.sessionVariables = {
    EDITOR = "nano";
  };

  programs.home-manager.enable = true;

}