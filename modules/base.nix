# base configurations for the most configs
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  config = {
    users.groups.nix = { }; # allowed to connect to nix-daemon, multiuser
    #boot.cleanTmpDir = true;
    # Mount /tmp as tmpfs
    boot.tmp.useTmpfs = true;
    #services.timesyncd.enable = true;
    documentation = {
      enable = false;
      man.enable = true;
      nixos.options.warningsAreErrors = false;
      info.enable = false;
    };
    nix = {
      settings = {
        sandbox = true;
        auto-optimise-store = true;
        cores = 0;
        allowed-users = [ "@nix" ];
        trusted-users = [ "@wheel" ];
      };
      distributedBuilds = true;

      # enable unstable flakes feature with newest nix command
      # keep settings cache outputs

      # keep-derivations
      # keep in mind, that your secrets will be exposed in /nix/store/*.drv files.
      # Use this only on a safe host to build the config and copy to the target one.
      # enable it if you develop on your config for cache and if you have no internet access
      # other options:
      # - access-tokens
      # - secret-key-files
      package = pkgs.nixFlakes;
      extraOptions = (
        lib.optionalString (
          config.nix.package == pkgs.nixFlakes
        ) "experimental-features = nix-command flakes"
        + ''

          keep-derivations = true
          keep-outputs = true

          min-free = ${toString (100 * 1024 * 1024)}
          max-free = ${toString (1024 * 1024 * 1024)}
        ''
      );

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };

      #readOnlyStore = false;
    };
    nixpkgs.config = {
      allowUnfree = true;
    };
  };
}
