# Devbook

## v0.2 - autoinstall and luks

### add

- [x] (I) add: autoinstall use github access tokens as default
- [x] (I) change: update to nixos 23.05 release
- [x] (I) add: offline builds to isoinstall, available with install-system and the autoinstall.system option
- [x] (F) add: disko paritioning to autoinstall
- [x] (F) add: luks disk encryption with disko
- [x] (I) change: seperate repos: nix-configs (general), nix-secrets (private), nix-hosts
- [x] (F) add: sshd initrd encryption keys
- [x] (I) change: base nodocumentation on system
- [x] (R) remove: delete old hardware-configuration, transfer to gist
- [ ] (I) change: modules to real nixos modules
- [ ] (I) add: default ripx80 grub splash image everywhere

- [ ] (F) add: initrd - include wireguard and connect to wg server. so no static ip is needed to connect to
- [ ] (F) add: initrd - use dhcp address in combination with dhcp option

- [ ] (F) add: tpm - need secure boot to protect: comming soon from the nix community
- [ ] (F) add: macos build [vm](https://www.tweag.io/blog/2023-02-09-nixos-vm-on-macos/)

- [ ] (I) change: add specialized autoinstall iso with a small size
- [ ] (I) change: restructure flake outputs in seperate files
- [ ] (I) change: to new password hashes with mkpasswd
- [ ] (I) add: offline builds for installed system
- [ ] (F) add: apps in flake like mkiso, startvm
- [ ] (I) change: wireshark config, hm not support enable
- [ ] (F) add: silent mode: disable all communication services
- [ ] (F) add: headscale module
- [ ] (F) add: router firewall config
- [ ] (F) add: knownHost, pub-ssh-userkey generator
- [ ] (F) add: starship config
- [ ] (T) test: check Stubby as a dnsproxy
- [ ] (F) add: documentation with asciinema
- [ ] (F) add: disko - snapshot task for btrfs subvolumes
- [ ] (I) change: luks -  must be replace by a real encryption key
- [ ] (I) add: luks - backup luksHeader
- [ ] (T) test: fix ignite
- [ ] (T) test: fix smartd, not tested, use mail
- [ ] (T) test: finish desktop.nix, test all audio stuff
- [ ] (T) test: home-manager on mac if all working, use isDarwin from lib
- [ ] (T) change: compare home-manager desktop with nixos desktop

## v0.1 - flakes

### add

- [x] (F) - add vmbuild
- [x] (F) - add profiles
- [x] handle secrets (sshkeys, wgkeys)
- [x] github signing
- [x] add flakes support
- [x] add devshell support
- [x] spotify
- [x] audio
- [x] go
- [x] rust
- [x] vscode
- [x] home-manager
- [x] wireguard config
- [x] dual boot with windows
- [x] ssh keys: user, copy per hand
- [x] wireguard serverip, serverpub, privkey
- [x] keybase
- [x] vscode switch to internal settings sync
- [x] special boot splash background
- [x] disable ssh pwd login, only with good keys
- [x] mac support with home-manager
- [x] piff to flakes module
- [x] paladin to flakes module
- [x] nix-darwin

### remove

- [x] ops dir and meta configuration

### change

- [x] (I) - update autoinstall
- [x] (I) - restructure project
- [x] (I) - update docs with better descr and installation guide
- [x] (I) - switch from nix-shell to nix develop
- [x] global switch for home-manager desktop (home.nix to desktop.nix)
- [x] restruct lib
- [x] restruct user to a generic version
- [x] overlays and inputs

### Maybe

- [ ] setup for alpine container with nix
- [ ] better wireguard config system
- [ ] easy use of nix ignite vm
- [ ] add seperate btrfs volume for nix
- [ ] add wipes on every reboot, use btrfs snapshots
- [ ] caches, nixos cache
- [ ] (F) add: userinfo (func) return user info with profile
- [ ] (F) add: [satisfactory](https://github.com/Misterio77/nix-config/blob/main/modules/nixos/satisfactory.nix)
- [ ] (F) add: factorio server

## signal words

words to search in code:

- todo
- deprecated

## questions

### uncategoriezed

- how to use a nix cache in the local env?
- how can i encrypt with luks:
   [luks](https://nixos.wiki/wiki/Remote_LUKS_Unlocking)
   [drive](https://mudrii.medium.com/nixos-native-flake-deployment-with-luks-drive-encryption-and-lvm-b7f3738b71ca)

- how profiles work in nix? write it down! root -> system?
- how can i create .ssh/config file via nix
- use github workflows to test config as buildvm?
- use [flake-parts](https://flake.parts/), [doc](https://aldoborrero.com/posts/2023/01/15/setting-up-my-machines-nix-style/)

#### doc

- write hands-on doc to install a fresh box with stick and deploy-rs
- write down deployment access structure with key
- write how can i use [nix fmt](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html) in flakes?

#### tests (NixOS tests)

- what exactly nix flake check do?
- how can i test all flakes in test cases? container?
     [check](https://www.reddit.com/r/NixOS/comments/x5cjmz/how_do_you_create_your_own_flake_check/)
- can i use containers instead of vms to test my nixos configs?
- test cases [vm](https://nix.dev/tutorials/integration-testing-using-virtual-machines)

#### flakes

- can i use [flake parts](https://flake.parts//options/flake-parts.html) in a better way?
- how can i generate a host and user list easy with flakes?
 [generate hosts](https://myme.no/posts/2022-06-14-nixos-confederation.html)
 [example config](https://jdisaacs.com/blog/nixos-config/)
- how can i produce a container from nix flakes like [tweag](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
 [docker](https://blog.sekun.dev/posts/create-rust-binaries-and-docker-images-with-nix/)
- how can i use [flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus?)
- how can i use different profiles? .#ripbox system?
  add [profiles](https://github.com/serokell/deploy-rs#profile)
- how use flakes with my windows (WSL)
- how i use flakes with [go](https://flyx.org/nix-flakes-go/) or rust and direnv?

#### deployment

- how to use remote [builds](https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html)?
- how can i use nix store sign and verify?
  - (experimental), use binary cache?
- how can i use deploy-rs signing key to push closures?
  - If you require a signing key to push closures to your server, specify the path to it in the LOCAL_KEY environment variable.
- how can i work with nix and terraform to create containers and vms?
- how can i use [vault-secrets](https://github.com/serokell/vault-secrets) with sysemd secrets?
- how can i use different python versions?

#### iso

- how to use [ipxe](https://github.com/NixOS/equinix-metal-builders/blob/main/flake.nix) to test the iso installation?
- how to use a encrypted iso image for install to protect repo key?
- how create with iso lib a [selectable menu](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix) with different configs?

## knownHosts

example of default:

```nix
knownHosts = {
    "github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
};
```

## autoinstall private repo with deploy key

```nix
 services.autoinstall = {
    enable = true;
    disk = "/dev/sda"; # "/dev/nvme0n1";
    access = meta.repo-access; # private ssh deployment key
    flake = "git+ssh://git@github.com/ripx80/nix-configs#minimal"; # your flake to deploy (minimal)
};
```

in autoinstall this will be executed:

```sh
${config.system.build.nixos-install}/bin/nixos-install \
        --flake $flake \
        --no-root-passwd \
        --cores 0
```

## autoinstall private repo with access tokens

use the personal access tokens on github.com:

```txt
Settings -> Developer Settings -> Personal Access Tokens -> Fine-grained tokens (beta)
- 30 days before expire
- set only the "Only selected repos" to nix-config
- repo: allow contents to read-only
```

and in nix:

```nix
services.autoinstall = {
    enable = true;
    disk = "/dev/sda"; # "/dev/nvme0n1";
    access = meta.repo-token;
    flake = "git+https://ripx80:$ACCESS@github.com/ripx80/nix-configs#minimal"; # using personal access tokens (ro, expire)
};
```

in autoinstall this will be executed:

```sh
${config.system.build.nixos-install}/bin/nixos-install \
        --flake $flake \
        --no-root-passwd \
        --cores 0
```

## to doc

```sh
#you can run directly vms:
nix run .#nixosConfigurations.minimal.config.system.build.vm
```

## roles (todo)

- build: build the config for other hosts and itself
- install: install the minimal system or a host system
- minimal: base system for all hosts
- host: defined system for each maschine

## secrets

- public: you can share with the world
- meta: git-encrypted only a builder has access
- host: secrets that only the host knows

- installer:
  - need a priv ssh keyfile (readable from stick), maybe encrypt the installer?
  - can decrypt special files like initrd-sshd private key
todo: test: with lib; concatLists (mapAttrsToList (name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else []) config.users.users);

## autoinstall custom stick

```txt
# todo: generate a specialized usb install stick

# this will be included:
# nixos/modules/profiles/all-hardware.nix
# nixos/modules/installer/cd-dvd/iso-image.nix
# nixos/modules/profiles/installation-device.nix # can be replaced, copy the nix channel
# nixos/modules/profiles/minimal.nix
# nixos/modules/profiles/base.nix # includes tools

"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" # pre-defined, includes all
# normal: 846M best compr
# 711MB with best compr

#"${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
#"${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
#"${nixpkgs}/nixos/modules/profiles/minimal.nix"
#"${nixpkgs}/nixos/modules/profiles/installation-device.nix" # customize this: boot entries aso, auto login
```

## nixos-rebuild offline

try out:

- how can i rebuild offline?
- nixos-rebuild switch --option binary-caches “” --option substitute false
- system.includeBuildDependencies

## check stuff

```txt

# not tested
# copy-secret =
#     pkgs.writeScriptBin "copy-secret" ''
#     #!${pkgs.stdenv.shell}
#     sudo modprobe nbd # ls /dev/nbd*

#     qemu-img create -f qcow2 $1.qcow2 10000M

#     sudo qemu-nbd -c /dev/nbd0 $1.qcow2 # attach to /dev/nbd0
#     mkdir -p
#     mount /dev/nbd0 /tmp/mnt

#     umount /tmp/mnt
#     qemu-nbd -d /dev/nbd0 # detach
#     rmmod nbd
#     '';

# Load the minimum supported Rust version (MSRV) from the manifest
#manifest = lib.importTOML ./Cargo.toml;
#minRust = manifest.package.rust-version;
#minRust = "0.1.0";

# user name as list from dir
#lib.attrNames(builtins.readDir(./users))

# lib.forEach (lib.attrNames(builtins.readDir(./users))) (x: genHome x)
# lib.forEach (lib.attrNames(builtins.readDir(./users))) (username: (lib.nameValuePair username (genHome username)))
#userList = lib.attrNames(builtins.readDir(./users)); # generate list of available users
#       genHome = user: path:(
#         mkHomeConfig {
#             inherit path;
#             username = user;
#             extraModules = [ path/${user}/home.nix ];
#         }
#   );

#   mkHomeConfigByPath = {path ? ./users}:(lib.forEach (lib.attrNames(builtins.readDir(path))) (username: lib.mapAttrs (lib.nameValuePair username (genHome username))));

/* # extend lib with hm
   lib = nixpkgs.lib.extend (final: prev:
       import ./lib {
           inherit home-manager;
           lib = final;
   });

   # NixOS machines
   nixosConfigurations = lib.myme.allProfiles ./machines (name: file:
       lib.myme.makeNixOS name file { inherit inputs system overlays; });

   # Non-NixOS machines (Fedora, WSL, ++)
   homeConfigurations = lib.myme.nixos2hm {
       inherit (self) nixosConfigurations;
       inherit overlays system;
   };


*/


  # todo: https://nixos.wiki/wiki/Flakes#:~:text=nix/pull/5434-,Importing,-packages%20from%20multiple
  # https://git.sr.ht/~raphi/molok/tree/master/item/flake.nix
  # https://github.com/nix-community/dream2nix/blob/main/flake.nix with checks
  # https://ayats.org/blog/no-flake-utils/
  # https://github.com/nix-community/dream2nix/blob/main/flake.nix with checks


  #flake = builtins.getFlake (toString ./.);
```

single flake update:
nix flake lock --update-input nixpkgs --update-input nix
