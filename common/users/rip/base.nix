{ config, pkgs, ... }:

{


  home.sessionVariables = {
    EDITOR = "nvim";
  };


  programs.home-manager.enable = true;


}