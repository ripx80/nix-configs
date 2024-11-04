{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.container;
  pkgDesc = "create relevant nix-container users and groups";
in
{
  options = {
    ripmod.container = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {
    # container user with group
    users.users = {
      container = {
        uid = 2000;
        group = "container";
        isSystemUser = true;
      };
    };
    users.groups.container = { };
  };
}
