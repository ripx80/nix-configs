{ self, lib, pkgs, inputs, pub, home-manager, disko }: {
  # generate a base nixos configuration with the
  # specified overlays, hardware modules, and any extraModules applied
  mkNixosConfig = { system ? "x86_64-linux", nixpkgs ?
      pkgs # nixpkgs without overlay as default: todo switch to pkgs break vm.nix
    , unstable ? pkgs.unstable, hardwareModules ? [
      (inputs.self + /modules/hardware.nix)
      (import (inputs.self + /modules/disko) {
        disks = [
          "/dev/sda" # default, /dev/nvme0n1
        ];
      })
    ], baseModules ? [
      self.nixosModules.nix-configs
      home-manager.nixosModules.home-manager
      disko.nixosModules.disko
    ], extraModules ? [ ], extraSpecialArgs ? { }, pubs ? pub, }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = baseModules ++ hardwareModules ++ extraModules;
      specialArgs = {
        pub = pubs;
        inherit nixpkgs inputs system unstable; # use nixpkgs.unstable
      } // extraSpecialArgs;
    };

  # generate a home-manager configuration usable on any unix system
  # with overlays and any extraModules applied
  mkHomeConfig = { username, system ? "x86_64-darwin"
    , nixpkgs ? inputs.nixpkgs-unstable, stable ? inputs.nixpkgs
    , baseModules ? [
      ./hm
      {
        home = {
          inherit username;
          homeDirectory = "${lib.ripmod.homePrefix system}/${username}";
          sessionVariables = {
            NIX_PATH =
              "nixpkgs=${nixpkgs}:stable=${stable}\${NIX_PATH:+:}$NIX_PATH";
          };
        };
      }
    ], extraModules ? [ ], }:
    inputs.home-manager.lib.homeManagerConfiguration rec { # unstable home-manager
      pkgs = import nixpkgs {
        inherit system;
        #overlays = overlays;
      };
      extraSpecialArgs = { inherit inputs nixpkgs; };
      modules = baseModules ++ extraModules;
    };

}
