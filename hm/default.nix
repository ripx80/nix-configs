{ lib, pkgs, specialArgs, ... }:
(let
  stateVersion = if builtins.hasAttr "nixosConfig" specialArgs then
    specialArgs.nixosConfig.system.stateVersion
  else
    "23.11"; # todo as argu
in {
  imports = [ ./desktop.nix ]; # todo
  config = {

    # Pass stateVersion from NixOS config
    #home.stateVersion = specialArgs.nixosConfig.system.stateVersion;
    home.stateVersion = stateVersion;
    home.sessionVariables = { EDITOR = "nano"; };

    programs.home-manager = {
      enable = true;
      #path = ".";
    };
  };
})
