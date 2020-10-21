# NixOS

[doc](https://nixos.org/nixos/manual/)
[archpipe](https://github.com/ripx80/archpipe/blob/master/web/prepare.sh)
[xeconfig](https://github.com/Xe/nixos-configs/blob/master/hosts/shachi/configuration.nix)
https://nixos.wiki/wiki/Overlays
https://nixos.wiki/wiki/Storage_optimization
https://github.com/symphorien/nix-du/
https://search.nixos.org/options
https://github.com/nix-community/awesome-nix
https://github.com/NixOS/nixops
https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows
https://nixos.org/guides/nix-pills/
https://nixos.wiki/wiki/Flakes
https://github.com/srid/nix-config
https://rycee.gitlab.io/home-manager/options.html
https://christine.website/blog/i-was-wrong-about-nix-2020-02-10
https://github.com/Mic92/dotfiles
https://github.com/Mic92/sops-nix

```sh
# list all system packages
nixos-option environment.systemPackages
# list all installed packages
nix-store --query --requisites /run/current-system
# with clear output
nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq
# packages in user profile
nix-env --query
# packages in roots profile
sudo nix-env --query
# found out who is use this dep
nix-store -q --referrers <file>
# show store by size
nix path-info -rS /run/current-system | sort -nk2
# show dep graph of package
nix why-depends /run/current-system /nix/store/zxxxnfx1hh4h5s0ikrvg03c9jvh05vgv-unit-systemd-binfmt.service
# optimize the store
nix-store --optimise
# rebuild system with config
nixos-rebuild -I nixos-config=path/to/your/configuration.nix
# to remove all packages from my profile installed via nix-env and not in configuration
nix-env -e '*'
# delete old boot entries
sudo nix-collect-garbage -d
sudo nixos-rebuild boot
# upgrade the complete system
nixos-rebuild switch --upgrade
#search for package
nix-env -qaP 'aspell.*en'
```

## Base Configuration

- dont use the default nixos base config, how can I build my own systemPackages
- lib.mkForce remove packages?
- use profiles for user (rip-work, rip-priv)

## Software

### Base

- nano (included in system profile)

### Desktop (minimal)

- zathura
- openbox
- alacrytty
- chrome
- vscode

### Overlays

- docker
- wireguard

### additonal apps


## home-manager

https://nixos.wiki/wiki/Home_Manager
https://github.com/nix-community/NUR#integrating-with-home-manager

## wireguard

wireguad config isnt a good impl. So for my needs I will write the rust tool for server and client.
maybe I can do something with preup and postdown

## todo

- [x] spotify
- [x] audio
- [x] go
- [x] rust
- [x] vscode
- [x] home-manager
- [x] wireguard config

- [ ] handle secrets
    - [x] ssh keys: user, copy per hand
    - [x] wireguard serverip, serverpub, privkey
    - [ ] gpg-keys, github signing
- [ ] global switch for home-manager desktop (home.nix to desktop.nix)

- [ ] add seperate btrfs volume for nix
- [ ] add wipes on every reboot, use btrfs snapshots
- [ ] caches
- [ ] nixopts
- [ ] dual boot with windows
- [ ] learn nix pills
- [ ] flakes

## Install Procedure

- fmt harddrive
- add chaneels

```sh
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
#nix-channel --add https://github.com/Mic92/sops-nix/archive/master.tar.gz sops-nix
nix-channel --update

git clone ssh://github.com/ripx80/nix-configs
ln -s /home/rip/nix-configs/hosts/vm/configuration.nix /etc/nixos/configuration.nix

# cp secrets to home
chown -R rip.users secrets
find . -type f -exec chmod 600 secrets
find . -type d -exec chmod 700 secrets

ln -s /home/rip/nix-configs/secrets secrets

# keep things private, in enterprise use vault
ln -s /home/rip/nix-configs/secrets/user/rip/ssh/ /home/rip/.ssh/
```


I manage all my systems via nixops with all configuration in a ~/nixops 71 (including secrets, which are encrypted with git-crypt). To deploy a system I cd into it and run make $(hostname) which expands to nixops modify -d $(hostname) systems/$(hostname) && nixops deploy -d $(hostname) and some other commands (depending on the hostname). The target system requires an SSH server, even if you’re deploying locally.

https://nixos.wiki/wiki/Flakes

xserver: https://gist.github.com/bennofs/bb41b17deeeb49e345904f2339222625
        https://discourse.nixos.org/t/nixos-without-a-display-manager/360/10
caching: https://cachix.org/