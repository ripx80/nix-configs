{ config, pkgs, ... }:

{
  imports =
  [
      ./neofetch.nix
  ];
  home.sessionVariables = {
    EDITOR = "nano";
  };

  home.packages = [
    pkgs.unzip
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };

}