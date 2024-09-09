{
  description = "rip's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      #url = "github:nix-community/home-manager"; # unstable
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      disko,
      ...
    }@inputs:
    let
      stateVersion = "24.05";
      version = builtins.substring 0 8 self.lastModifiedDate;

      # Helper generating outputs for each supported system
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        #"aarch64-linux"
      ];
      pub = import ./pub.nix;

      # check: https://codeberg.org/totoroot/dotfiles/src/branch/main/flake.nix
      #   lib = nixos.lib.extend
      #     (final: prev: { ripmod = import ./lib { inherit pkgs inputs; lib = final; }; });

      # todo: with lib it must be a better solution
      lib = nixpkgs.lib.extend (
        final: prev:
        let
          pkgs = self.pkgs."x86_64-linux";
        in
        {
          ripmod =
            # prev (super) -> points to lib before extension
            # final (self) -> points to lib after extension
            import ./lib {
              inherit
                self
                inputs
                pkgs
                pub
                home-manager
                disko
                ;
              lib = prev;
            }
            // {
              systemModules = rec {
                base = [
                  ./modules/base.nix
                  (
                    { config, pkgs, ... }:
                    {
                      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev; # nixos-version --json must be a clean git
                      system.stateVersion = stateVersion;
                      nix.registry.nixpkgs.flake = nixpkgs;
                      ripmod = {
                        deploy = {
                          enable = true;
                          keys = pub.deploy;
                        };
                        locale.enable = true;
                      };
                    }
                  )
                ];

                minimal = base ++ [ ./modules/minimal.nix ];

                dev = [
                  (
                    {
                      config,
                      pkgs,
                      lib,
                      ...
                    }:
                    {
                      environment.systemPackages = [ pkgs.git ];
                      ripmod.desktop.enable = true;
                    }
                  )
                ];
                vm = [ ./modules/vm.nix ];
              };
            };
        }
      );
    in
    {
      inherit lib;
      # todo: import, not working at the moment
      nixosModules = {
        nix-configs = {
          imports = [ ./modules ];
        };
      };

      pkgs = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
          config.allowAliases = true;
        }
      );

      overlays = import ./nix/overlay.nix inputs;

      packages = forAllSystems (system: {
        whispercpp = self.pkgs.${system}.whispercpp;
        minimal = self.nixosConfigurations.minimal-vm.config.system.build.vm;
        darwin-vm = self.nixosConfigurations.darwin-vm.config.system.build.vm;
      });

      formatter = forAllSystems (system: self.pkgs.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = self.pkgs.${system};
        in
        {
          # Check Nix formatting
          nixfmt =
            pkgs.runCommand "check nix format in project" { buildInputs = [ pkgs.nixfmt-rfc-style ]; }
              ''
                echo "checking nix formatting"
                find ${./.} -name '*.nix' | xargs ${pkgs.nixfmt-rfc-style}/bin/nixfmt --check
                touch $out
              '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = self.pkgs.${system};
        in
        {
          # Default dev shell (used by direnv)
          default = pkgs.mkShell {
            # inputsFrom
            # shellHook
            # packages
            # buildInputs: bash statements
            packages = with pkgs; [
              rage
              git-crypt
              lib.ripmod.mkiso
              lib.ripmod.nix-fmt
              #lib.ripmod.deploy-key
            ];
          };
        }
      );

      nixosConfigurations = {
        /*
          minimal system with deployment access. can be used to deploy specific configs on top of it.
           $ nixos-rebuild build --flake .#minimal
        */
        minimal = lib.ripmod.mkNixosConfig {
          extraModules = lib.ripmod.systemModules.minimal ++ [
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                # networking.useDHCP = true;
                networking.hostName = "minimal";
              }
            )
          ];
        };

        /*
          minimal system in vm mode with deployment access. can be used to deploy specific configs
           $ nixos-rebuild build-vm --flake .#minimal-vm
           or:
           $ nix run .#minimal
        */
        minimal-vm = self.nixosConfigurations.minimal.extendModules {
          modules = lib.ripmod.systemModules.vm ++ [
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                users.mutableUsers = true;
                # Create user "test"
                services.getty.autologinUser = "test";
                users.users.test.isNormalUser = true;

                # Enable passwordless ‘sudo’ for the "test" user
                users.users.test.extraGroups = [ "wheel" ];
                security.sudo.wheelNeedsPassword = false;
              }
            )
          ];
        };

        # nixos vm running on a darwin system
        darwin-vm = self.nixosConfigurations.minimal-vm.extendModules {
          modules = lib.ripmod.systemModules.vm ++ [
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                networking.useDHCP = false;
                networking.nameservers = [ "8.8.8.8" ];
                virtualisation.vmVariant.virtualisation.graphics = false;
                virtualisation.vmVariant.virtualisation.host.pkgs = nixpkgs.legacyPackages.x86_64-darwin;
              }
            )
          ];
        };

        /*
          generate a iso with autoinstall systemd-oneshot to part the disk and install the given flake
           $ mkiso
           or
           $ nix build .#nixosConfigurations.autoinstall

           test the iso in vm
           $ qemu-img create -f qcow2  autoinstall.img 20G

           with nvme
           $ qemu-system-x86_64 -boot d -cdrom result/iso/nixos-*linux.iso -smp $(nproc) -cpu max -m 4096 -drive file=autoinstall.img,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm -net user,hostfwd=tcp::2222-:22 -net nic

           normal disk
           $ qemu-system-x86_64 -boot d -cdrom result/iso/nixos-*linux.iso -smp $(nproc) -cpu max -m 4096 -drive file=autoinstall.img -net user,hostfwd=tcp::2222-:22 -net nic

           boot in efi mode
           $ qemu-system-x86_64 -m 512 -drive file=autoinstall.img,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm -net user,hostfwd=tcp::2222-:22 -net nic -bios /nix/store/bqlgjk6m29j6jdrm27280yb3mdznrx1h-OVMF-202202-fd/FV/OVMF.fd

          # test
           qemu-system-x86_64 -boot d -cdrom result/iso/nixos-22.11.20230419.3d302c6-x86_64-linux.iso -m 512 -drive file=autoinstall.img,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm -net user,hostfwd=tcp::2222-:22 -net nic -bios /nix/store/b1wfhkbvw1rjyndnq3mir0cjvp21n3bn-OVMF-202205-fd/FV/OVMF.fd
           qemu-system-x86_64 -boot d -cdrom result/iso/nixos-22.11.20230419.3d302c6-x86_64-linux.iso -m 512 -drive file=autoinstall.img,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm -net user,hostfwd=tcp::2222-:22 -net nic -bios $(readlink -f /run/libvirt/nix-ovmf/OVMF_CODE.fd)

           copy to usb stick
           sudo dd if=$(echo result/iso/nixos*.iso) of=/dev/sdc bs=4M # this will delete all data on /dev/sdc
        */
        iso = lib.ripmod.mkNixosConfig {
          hardwareModules = [ ]; # must be specified on extended module
          extraModules = lib.ripmod.systemModules.base ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                boot.supportedFilesystems = [
                  "btrfs"
                  "vfat"
                ]; # reduced from profile/base.nix
                isoImage.squashfsCompression = "zstd -Xcompression-level 6"; # faster but large, default: best compression use for prod
                #system.nixos.label = "ripos";
                isoImage = {
                  # not working at the moment
                  #splashImage = ./modules/boot/splash/splash.png;
                  #efiSplashImage = ./modules/boot/splash/splash.png; # not working?

                  #grubTheme = null; # open bug canot set to null, so the background image never used: https://github.com/NixOS/nixpkgs/pull/156754
                  # https://github.com/NixOS/nixos-artwork/tree/master/bootloader/grub2-installer
                  prependToMenuLabel = "ripx80 - ";
                  appendToMenuLabel = version;
                };
              }
            )
          ];
        };

        autoinstall = self.nixosConfigurations.iso.extendModules {
          modules = [
            (import ./modules/disko { disks = [ "/dev/sda" ]; })
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                ripmod.autoinstall = lib.mkDefault {
                  enable = true;
                  autorun = false;
                  system = self.nixosConfigurations.minimal.config.system.build.toplevel;
                };
              }
            )
          ];
        };
      };

      #nixosConfigurations.ripbox.config.home-manager.users.rip
      homeConfigurations = {
        rip = lib.ripmod.mkHomeConfig {
          username = "rip";
          system = "x86_64-darwin";
          extraModules = [ ./users/rip/home.nix ];
        };
        rip_x86_64 = lib.ripmod.mkHomeConfig {
          username = "rip";
          system = "x86_64-linux";
          extraModules = [ ./users/rip/home.nix ];
        };
        peter = lib.ripmod.mkHomeConfig {
          username = "peter";
          system = "x86_64-darwin";
          extraModules = [ ./users/peter/home.nix ];
        };
        peter_x86_64 = lib.ripmod.mkHomeConfig {
          username = "rip";
          system = "x86_64-linux";
          extraModules = [ ./users/peter/home.nix ];
        };
      };
    };
}
