{
  self,
  lib,
  pkgs,
  inputs,
  pub,
  home-manager,
  disko,
}:
let

  isDarwin = system: (builtins.elem system lib.platforms.darwin);
  homePrefix = system: if isDarwin system then "/Users" else "/home";
in
{
  fetchKeys = username: (builtins.fetchurl "https://github.com/${username}.keys");
  mkiso = pkgs.writeScriptBin "mkiso" ''
    #!${pkgs.stdenv.shell}
    SYSTEM="''${1:-autoinstall}"
    ${pkgs.nixVersions.latest}/bin/nix build .#nixosConfigurations.''${SYSTEM}.config.system.build.isoImage
  '';
  nix-fmt = pkgs.writeScriptBin "nix-fmt" ''
    #!${pkgs.stdenv.shell}
    find ./. -name '*.nix' | xargs nix fmt
  '';
  isDarwin = isDarwin;
  homePrefix = homePrefix;
  #   deploy-key = pkgs.writeScriptBin "deploy-key" ''
  #     #!${pkgs.stdenv.shell}
  #     set -exo pipefail

  #     if [ "$#" -eq 2 ]
  #     then
  #         DEPLOY_SECRETS="''${1}"
  #         DEPLOY_HOST="''${2}"
  #     fi

  #     if [ -z ''${DEPLOY_SECRETS+x} ] || [ -z ''${DEPLOY_HOST+x} ]
  #       then
  #         echo "set the following env vars:"
  #         echo "DEPLOY_SECRETS="
  #         echo "DEPLOY_HOST="
  #         echo "or use the command: deploy-key <secrets dir> <deploy host>"
  #         exit 1
  #     fi
  #     scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ''${DEPLOY_SECRETS}/deploy/id_ed25519 ''${DEPLOY_SECRETS}/''${DEPLOY_HOST}/ssh_host_ed25519_key* deploy@''${DEPLOY_HOST}:~
  #     ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ''${DEPLOY_SECRETS}/deploy/id_ed25519 deploy@''${DEPLOY_HOST} -C "sudo install -m 0600 -o root -g root ~/ssh_host_ed25519_key* /etc/ssh/ && rm ~/ssh_host_ed25519_key* && sudo systemctl restart sshd"
  #   '';

  genIPMask = a: b: a + ("/" + (toString b)); # generate <ip>/<prefix>
  genIPPort = a: b: a + (":" + (toString b)); # generate <ip>:<port>

  # generate a base nixos configuration with the
  # specified overlays, hardware modules, and any extraModules applied
  mkNixosConfig =
    {
      system ? "x86_64-linux",
      # nixpkgs without overlay as default: todo switch to pkgs break vm.nix
      hardwareModules ? [
        (self + /modules/hardware.nix)
        (import (self + /modules/disko) {
          disks = [
            "/dev/sda" # default, /dev/nvme0n1
          ];
        })
      ],
      baseModules ? [
        self.nixosModules.nix-configs
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
      ],
      extraModules ? [ ],
      extraSpecialArgs ? { },
      pubs ? pub,
      usepkgs ? pkgs,
    }:
    lib.nixosSystem {
      inherit system;
      modules = baseModules ++ hardwareModules ++ extraModules;
      specialArgs = {
        pub = pubs;
        pkgs = usepkgs;
        inherit inputs system; # use nixpkgs.unstable
      } // extraSpecialArgs;
    };

  # generate a home-manager configuration usable on any unix system
  # with overlays and any extraModules applied
  mkHomeConfig =
    {
      username,
      system ? "x86_64-darwin",
      nixpkgs ? inputs.nixpkgs-unstable,
      stable ? inputs.nixpkgs,
      baseModules ? [
        ../hm
        {
          home = {
            inherit username;
            homeDirectory = homePrefix system + "/" + username;
            sessionVariables = {
              NIX_PATH = "nixpkgs=${nixpkgs}:stable=${stable}\${NIX_PATH:+:}$NIX_PATH";
            };
          };
        }
      ],
      extraModules ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration rec {
      # unstable home-manager
      pkgs = import nixpkgs {
        inherit system;
        #overlays = overlays;
      };
      extraSpecialArgs = {
        inherit inputs nixpkgs;
      };
      modules = baseModules ++ extraModules;
    };
}
