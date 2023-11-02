/* todo: check this module
    root need access to the private key file to connect to the builder server.
    do this as a secret. use the maschine sshd key for this.
*/
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.builder;
  pkgDesc = "distributed builder for nix packages. server and client options";
in {
  options = {
    ripmod.builder = {
      enable = mkEnableOption pkgDesc;
      hostname = mkOption {
        type = types.str;
        default = false;
        description =
          "allow to build on this host. it will create a build user.";
      };
      privKeyPath = mkOption {
        type = types.str;
        default = "/etc/ssh/ssh_host_ed25519_key";
        description =
          "set the path to the private key to connect to the build host. default is the host key";
      };
      keys = mkOption {
        description = "ssh pub key for builder access";
      }; # only for server
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable && cfg.hostname) {
      # client
      nix = {
        distributedBuilds = true;
        buildMachines = [{
          hostName = cfg.server;
          sshUser = "builder";
          sshKey = cfg.privKeyPath;
          system = "x86_64-linux"; # ["x86_64-linux" "aarch64-linux"];
          protocol = "ssh-ng";
          maxJobs = 10;
          speedFactor = 2;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        }];
        # optional, useful when the builder has a faster internet connection than yours
        extraOptions = ''
          builders-use-substitutes = true
        '';
        # build-users-group = nixbld
      };
    })
    (mkIf (cfg.enable && !cfg.hostname) {
      # server
      users = {
        groups.builder = { };
        users.builder = {
          isSystemUser = true;
          openssh.authorizedKeys.keys = cfg.keys;
          group = "builder";
          extraGroups = [ "nix" ];
        };
      };
    })
  ];

}
