{ config, lib, pkgs, ... }:

{
  lib = {
      config = {
        boot.cleanTmpDir = true;
        nix = {
        autoOptimiseStore = true;
        gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 7d";
        };
        trustedUsers = [ "root" "rip" ];
        };
        nixpkgs.config = {
            allowUnfree = true;
            packageOverrides = pkgs: {
            nur = import (builtins.fetchTarball
                "https://github.com/nix-community/NUR/archive/master.tar.gz") {
                    inherit pkgs;
                };
            };
        };
      };
    };
}
