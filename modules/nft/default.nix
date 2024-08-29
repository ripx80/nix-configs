{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ ./ingress-ddos.nix ];
}
