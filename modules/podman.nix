{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.podman;
  pkgDesc = "enable podman";
in
{
  options = {
    ripmod.podman = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    # run podman containers as systemd services
    virtualisation.oci-containers = {
      backend = "podman";
      #   containers.containers = {
      #      container-name = {
      #        image = "container-image";
      #        autoStart = true;
      #        ports = [ "127.0.0.1:1234:1234" ];
      #      };
    };
  };
}
