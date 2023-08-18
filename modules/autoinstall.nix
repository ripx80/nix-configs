/* add tests, only system or flake can be set
    if flake is set, it will be used in the autorun service
    if flake is not set system will be used
*/
{ config, lib, pkgs, pub, ... }:
with lib;
let
  cfg = config.ripmod.autoinstall;
  pkgDesc =
    "autoinstall for flakes on vms or bare metal. will be wipe the current system";
in {
  options.ripmod.autoinstall = {
    enable = mkEnableOption pkgDesc;

    system = mkOption rec {
      type = types.package;
      default = null;
      description = "toplevel system";
    };

    flake = mkOption rec {
      type = types.str;
      default = "";
      example = ''
        deploy key: git+ssh://git@github.com/ripx80/nix-configs#minimal
        access token:
            git+https://ripx80:$ACCESS@github.com/ripx80/nix-configs#minimal
            git+https://ripx80:<repo-token>@github.com/ripx80/nix-configs#minimal
      '';
      description =
        "absolute path to the flake with url. use a deployment key or a access token";
    };

    accessKey = mkOption {
      type = types.str;
      default = "";
      description =
        "ssh access key for private repo access. will be used to fetch the config";
    };

    autorun = mkOption {
      type = types.bool;
      default = true;
      description = "run the auto install process via systemd";
    };

    secretKey = mkOption {
      type = types.str;
      default = "password";
      description =
        "if you use luks encryption you can set your secret key here. this will be passed to cryptsetup";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.flake != "") {
      environment.systemPackages = let
        # online flake repo installation
        install-flake = pkgs.writeShellScriptBin "install-flake" ''
            set -euo pipefail
            # generate luks keys
            echo -n "${cfg.secretKey}" > /root/secret.key
            echo "Formatting disks..."
            disko-format

            echo "Mounting disks..."
            disko-mount

            echo "Installing system..."
            ${config.system.build.nixos-install}/bin/nixos-install \
          --flake ${cfg.flake} \
          --no-root-passwd \
          --cores 0

            echo "Done!"
        '';
      in [ install-flake ];
    })
    # offline build with included toplevel system
    # be aware of your secrets they will be included here
    (mkIf (cfg.system != null) {
      environment.systemPackages = let
        install-system = pkgs.writeShellScriptBin "install-system" ''
          set -euo pipefail

          # generate luks keys
          echo -n "${cfg.secretKey}" > /root/secret.key

          echo "Formatting disks..."
          disko-format

          echo "Mounting disks..."
          disko-mount

          echo "Installing system..."
          nixos-install --system ${cfg.system} \
          --no-root-passwd \
          --cores 0

          echo "Done!"
        '';
      in [ install-system ];
    })
    (mkIf (cfg.accessKey != "") {
      systemd.services.repo-access = {
        description = "add deployment key to ssh config";
        wantedBy = [ "multi-user.target" ];
        before = [ "autoinstall.service" ];
        path = [ "/run/current-system/sw/" ];
        script = with pkgs; ''
          set -euo pipefail
          eval "$(ssh-agent)"
          ssh-add - <<< "$ACCESS"
        '';
        environment = config.nix.envVars // {
          inherit (config.environment.sessionVariables) NIX_PATH;
          HOME = "/root";
          ACCESS = "${cfg.accessKey}";
        };
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    })
    ({
      environment.systemPackages = let
        disko =
          pkgs.writeShellScriptBin "disko" "${config.system.build.diskoScript}";
        disko-mount = pkgs.writeShellScriptBin "disko-mount"
          "${config.system.build.mountScript}";
        disko-format = pkgs.writeShellScriptBin "disko-format"
          "${config.system.build.formatScript}";
      in [ pkgs.git disko disko-mount disko-format ];

      disko.enableConfig = lib.mkForce
        false; # we don't want to generate filesystem entries on this image

      systemd.services.autoinstall = let
        cmd = if cfg.flake != null then "install-flake" else "install-system";
      in {
        enable = cfg.autorun;
        description = "bootstrap a nixos installation";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "network-online.target" "polkit.service" ];
        path = [ "/run/current-system/sw/" ];
        script = with pkgs; ''
            set -euo pipefail
            echo 'journalctl -fb -n100 -uautoinstall' >>~nixos/.bash_history

          ${cmd}

            echo "done..."
            echo 'Shutting off...'
            #${systemd}/bin/shutdown now
        '';
        environment = config.nix.envVars // {
          inherit (config.environment.sessionVariables) NIX_PATH;
          HOME = "/root";
        };
        serviceConfig = {
          Type = "oneshot";
          User =
            "root"; # must be root, nixos-install create with mktemp files under /mnt/tmp.XXXXXXX
        };
      };
    })
  ]);
}
