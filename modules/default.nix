{ pkgs, config, lib, ... }: {
  imports = [
    ./podman.nix
    ./banner.nix
    ./boot
    ./dnscrypt.nix
    ./hardware.nix
    ./deploy.nix
    ./power.nix
    ./smart.nix
    ./virtualbox.nix
    ./ssh.nix
    ./locale.nix
    ./ignite.nix
    ./headscale.nix
    ./tailscale.nix
    ./initrd-ssh.nix
    ./unbound.nix
    ./monitoring/grafana-agent
    ./autoinstall.nix
    ./watermark.nix
    ./desktop.nix
    ./net-local.nix
  ];
}
