# NixOS

[doc](https://nixos.org/nixos/manual/)
[archpipe](https://github.com/ripx80/archpipe/blob/master/web/prepare.sh)
[xeconfig](https://github.com/Xe/nixos-configs/blob/master/hosts/shachi/configuration.nix)
https://nixos.wiki/wiki/Overlays
https://nixos.wiki/wiki/Storage_optimization
https://github.com/symphorien/nix-du/
https://nixos.wiki/wiki/Home_Manager

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

- spotify

I manage all my systems via nixops with all configuration in a ~/nixops 71 (including secrets, which are encrypted with git-crypt). To deploy a system I cd into it and run make $(hostname) which expands to nixops modify -d $(hostname) systems/$(hostname) && nixops deploy -d $(hostname) and some other commands (depending on the hostname). The target system requires an SSH server, even if you’re deploying locally.