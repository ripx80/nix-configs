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

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "ripx80";
    userEmail = "ripx80@protonmail.com";
    # signing = {
    #   key = "me@yrashk.com";
    #   signByDefault = true;
    # };
  };

}