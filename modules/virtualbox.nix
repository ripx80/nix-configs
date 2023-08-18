{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ripmod.virtualbox;
  pkgDesc = "enable virtualbox settings";
in {
  options = {
    ripmod.virtualbox = {
      enable = mkEnableOption pkgDesc;
      users = mkOption {
        default = [ "rip" ];
        examples = ''users = [ "username" ];'';
        description = "users added to vbox group";
      };
      extInt = mkOption {
        default = [ "rip" ];
        examples = ''externalInterface = "enp1s0";'';
        description = "external interface";
      };
    };
  };
  config = mkIf cfg.enable {

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1; # vm support
      #"net.ipv6.conf.all.forwarding" = 1;
    };
    virtualisation = {
      virtualbox = {
        host.enable = true; # increase build time
        host.enableExtensionPack = true; # a lot of stuff to compile
      };
    };
    users.extraGroups.vboxusers.members = cfg.users;
    networking = {
      nat = {
        enable = true;
        externalInterface = cfg.extInt;
        internalInterfaces = [ "ve-+" ];
      };
    };
  };
}
