{ lib, pkgs, specialArgs, ... }:
(let
  stateVersion = if builtins.hasAttr "nixosConfig" specialArgs then
    specialArgs.nixosConfig.system.stateVersion
  else
    "23.05"; # todo as argu
in {
  imports = [ ./desktop.nix ]; # todo
  config = {

    # Pass stateVersion from NixOS config
    #home.stateVersion = specialArgs.nixosConfig.system.stateVersion;
    home.stateVersion = stateVersion;

    home.sessionVariables = { EDITOR = "nano"; };

    #home-manager.useGlobalPkgs = true;
    #home-manager.useUserPackages = true;

    programs.home-manager = {
      enable = true;
      #path = ".";
    };
  };
})
