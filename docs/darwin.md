# Manage darwin with nix

at the moment this is too unstable. check it out later.

## flake

```nix
darwin.url = "github:lnl7/nix-darwin";
darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

darwinConfigurations = {
    ripmc = lib.ripmod.mkDarwinConfig {
    extraModules = [
        ./users/rip
        ({ config, pkgs, ... }: {
        home-manager.users.rip.home.packages = with pkgs; [ vscode git ];
        })
    ];
    };
};
```

## lib

```nix
#   generate a base darwin configuration with the
#   specified hostname, overlays, and any extraModules applied
#   too unstable at the moment
mkDarwinConfig = { system ? "x86_64-darwin", nixpkgs ? pkgs
, stable ? inputs.stable, baseModules ? [
    home-manager.darwinModules.home-manager
    ./modules/base-darwin.nix
], extraModules ? [ ], pubs ? pub }:
inputs.darwin.lib.darwinSystem {
    inherit system;
    modules = baseModules ++ extraModules;
    specialArgs = {
    pub = pubs;
    inherit inputs nixpkgs system;
    };
};
```

## base config

```nix
# this is a nix-darwin configuration not a nixos config
{ config, pkgs, lib, ... }: {
  nix = {
    settings = {
      sandbox = true;
      auto-optimise-store =
        false; # disable bug: https://github.com/NixOS/nix/issues/7273
      cores = 0;

    };
    distributedBuilds = true;
    package = pkgs.nixFlakes;
    extraOptions = (lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes" + ''

        keep-derivations = true
        keep-outputs = true
      '');

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    nixpkgs.config.allowUnsupportedSystem = true; # cross-compile
  };
  services.nix-daemon.enable = true;
  time.timeZone = "Europe/Berlin";
}
```
