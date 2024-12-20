# save file location: ~/.config/Epic/FactoryGame/Saved/SaveGames
# steam log file location: ~/.local/share/Steam/logs
# game log file location: ~/SatisfactoryDedicatedServer/FactoryGame/Saved/Logs
# todo: can not import satisfactory module inside a container or vm.
# todo: find a good way to create /var/lib/satisfactory
# ripmod = {
# virt.network.enable = true;
#     satisfactory = {
#       enable = true;
#       extraSteamCmdArgs = "-log -DisableSeasonalEvents";
#     };
# };

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.satisfactory;
  pkgDesc = "satisfactory dedicated server";
in
{
  options = {
    ripmod.satisfactory = {
      enable = mkEnableOption pkgDesc;
      beta = lib.mkOption {
        type = lib.types.enum [
          "public"
          "experimental"
        ];
        default = "public";
        description = "Beta channel to follow";
      };

      #   address = lib.mkOption {
      #     type = lib.types.str;
      #     default = "0.0.0.0";
      #     description = "Bind address";
      #   };

      maxPlayers = lib.mkOption {
        type = lib.types.number;
        default = 8;
        description = "Number of players";
      };

      autoPause = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Auto pause when no players are online";
      };

      autoSaveOnDisconnect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Auto save on player disconnect";
      };

      extraSteamCmdArgs = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = ''
          -log
          -unattended
          -DisableSeasonalEvents
        '';
        description = "Extra arguments passed to steamcmd command";
      };
    };
  };
  config = mkIf cfg.enable {
    # option as microvm: https://github.com/astro/microvm.nix
    containers.satisfactory = {
      autoStart = true;
      ephemeral = true; # destroy on reboot
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "192.168.178.11/24";
      bindMounts = {
        "/var/lib/satisfactory" = {
          hostPath = "/var/lib/satisfactory";
          isReadOnly = false;
        };
      };
      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          system.stateVersion = "24.05";
          nixpkgs.config.allowUnfree = true;
          environment.etc = {
            # fix resolv problems, when the host has other servers or connections
            # can be added as a container/ns.nix
            # route traffic from conterhost to wgnc
            "resolv.conf" = {
              text = ''
                nameserver 9.9.9.9
              '';
              mode = "0644";
            };
          };

          users.users.container = {
            home = "/var/lib/satisfactory";
            createHome = true;
            uid = 2000;
            group = "container";
            isSystemUser = true;
          };
          users.groups.container = { };

          networking = {
            defaultGateway = "192.168.178.1";
            firewall.enable = false;
          };

          #   systemd.tmpfiles.rules = [
          #     "d /var/lib/satisfactory 0700 container container -"
          #   ];
          #          systemd.services.runTmpfilesCreate = {
          #     description = "Run systemd-tmpfiles --create after deployment";
          #     serviceConfig = {
          #       ExecStart = "${pkgs.systemd}/bin/systemd-tmpfiles --create";
          #       Type = "oneshot";
          #     };
          #     # Startet den Dienst bei Bedarf, z. B. nach Änderungen an tmpfiles oder während eines Deployments.
          #     wantedBy = [ "multi-user.target" ];
          #   };

          #   systemd.timers.runTmpfilesCreateTimer = {
          #     description = "Timer to run systemd-tmpfiles after each deployment";
          #     wantedBy = [ "timers.target" ];
          #     timerConfig.OnBootSec = "5min";      # Wird 5 Minuten nach dem Booten ausgeführt
          #     timerConfig.OnUnitActiveSec = "1h";  # Wird dann jede Stunde ausgeführt, falls benötigt
          #   };

          systemd.services.satisfactory = {
            wantedBy = [ "multi-user.target" ];
            preStart = ''
              ${pkgs.steamcmd}/bin/steamcmd \
                +force_install_dir /var/lib/satisfactory/SatisfactoryDedicatedServer \
                +login anonymous \
                +app_update 1690800 \
                -beta ${cfg.beta} \
                ${cfg.extraSteamCmdArgs} \
                validate \
                +quit

                ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/FactoryServer-Linux-Shipping
                ln -sfv /var/lib/satisfactory/.steam/steam/linux64 /var/lib/satisfactory/.steam/sdk64
                mkdir -p /var/lib/satisfactory/SatisfactoryDedicatedServer/FactoryGame/Saved/Config/LinuxServer
                ${pkgs.crudini}/bin/crudini --set /var/lib/satisfactory/SatisfactoryDedicatedServer/FactoryGame/Saved/Config/LinuxServer/Game.ini '/Script/Engine.GameSession' MaxPlayers ${toString cfg.maxPlayers}
                ${pkgs.crudini}/bin/crudini --set /var/lib/satisfactory/SatisfactoryDedicatedServer/FactoryGame/Saved/Config/LinuxServer/ServerSettings.ini '/Script/FactoryGame.FGServerSubsystem' mAutoPause ${
                  if cfg.autoPause then "True" else "False"
                }
                ${pkgs.crudini}/bin/crudini --set /var/lib/satisfactory/SatisfactoryDedicatedServer/FactoryGame/Saved/Config/LinuxServer/ServerSettings.ini '/Script/FactoryGame.FGServerSubsystem' mAutoSaveOnDisconnect ${
                  if cfg.autoSaveOnDisconnect then "True" else "False"
                }
            '';
            #/var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/UnrealServer-Linux-Shipping FactoryGame -multihome=${cfg.address}
            script = ''
              /var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/FactoryServer-Linux-Shipping FactoryGame
            '';
            serviceConfig = {
              Restart = "always";
              User = "container";
              Group = "container";
              WorkingDirectory = "/var/lib/satisfactory";
            };
            environment = {
              LD_LIBRARY_PATH = "SatisfactoryDedicatedServer/linux64:SatisfactoryDedicatedServer/Engine/Binaries/Linux:SatisfactoryDedicatedServer/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu";
            };
          };
        };
    };
  };
}
