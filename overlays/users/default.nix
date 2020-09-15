{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

  users.users.rip = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.nushell;
  };

  #home-manager.users.cadey = (import ./rip/core.nix);
}