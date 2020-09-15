{ config, pkgs, ... }:

{
  users.users.rip = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.nushell;
  };
}