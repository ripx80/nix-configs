{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.deploy;
  pkgDesc = "enable deployment access";
in {
  options = {
    ripmod.deploy = {
      enable = mkEnableOption pkgDesc;
      keys =
        mkOption { description = "your ssh pub key for deployment access"; };
    };
  };

  config = mkIf cfg.enable {

    users = {
      groups.deploy = { };
      users.deploy = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = cfg.keys;
        group = "deploy";
        extraGroups = [ "wheel" "nix" ];
      };
    };
    security.sudo = {
      execWheelOnly = true;
      extraRules = [{
        users = [ "deploy" ];
        commands = [{
          command = "ALL";
          options = [ "NOPASSWD" ];
        }];
      }];
    };
  };
}
