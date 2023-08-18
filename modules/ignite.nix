# todo: not working
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.ignite;
  pkgDesc = "enable ignite toolkit";
in {

  options = { ripmod.ignite = { enable = mkEnableOption pkgDesc; }; };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    environment.systemPackages = [ pkgs.ignite ];
    # ignite need containerd running but when it runs as systemd service you canot create vms. run it in a shell it works
    #environment.systemPackages = [ pkgs.containerd pkgs.runc pkgs.ignite pkgs.binutils];
    # systemd.services.containerd = {
    #     enable = true;
    #     description = "containerd service";
    #     after = [ "network.target" ];
    #     wantedBy = [ "multi-user.target" ];
    #     script = ''
    #         #!${pkgs.stdenv.shell}
    #         ${pkgs.containerd}/bin/containerd
    #         '';
    # };
  };
}
