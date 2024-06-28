{ nixpkgs, nixpkgs-unstable, ... }:
let
  inherit (nixpkgs) lib;
  ov = lib.mapAttrs' (
    f: _: lib.nameValuePair (lib.removeSuffix ".nix" f) (import (./overlays + "/${f}"))
  ) (builtins.readDir ./overlays);
in
ov
// {
  default = lib.composeManyExtensions (
    [
      (final: prev: {
        #unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        unstable = import nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
        #nix-always-substitute = nix.packages.${final.stdenv.hostPlatform.system}.nix;
      })
    ]
    ++ (lib.attrValues ov)
  );
}
