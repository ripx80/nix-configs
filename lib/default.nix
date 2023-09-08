{ lib, pkgs, inputs }: {
  fetchKeys = username:
    (builtins.fetchurl "https://github.com/${username}.keys");
  isDarwin = system: (builtins.elem system lib.platforms.darwin);
  homePrefix = system: if lib.ripmod.isDarwin system then "/Users" else "/home";

  mkiso = pkgs.writeScriptBin "mkiso" ''
    #!${pkgs.stdenv.shell}
    SYSTEM="''${1:-autoinstall}"
    ${pkgs.nixUnstable}/bin/nix build .#nixosConfigurations.''${SYSTEM}.config.system.build.isoImage
  '';
  nix-fmt = pkgs.writeScriptBin "nix-fmt" ''
    #!${pkgs.stdenv.shell}
    find ./. -name '*.nix' | xargs nix fmt
  '';
}
