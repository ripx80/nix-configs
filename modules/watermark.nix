{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ripmod.watermark;
  pkgDesc = "watermark service";
in {
  options = {
    ripmod.watermark = {
      enable = mkEnableOption pkgDesc;

      disk = mkOption {
        type = types.str;
        default = "/dev/sda";
        description = "disk where to delete, default: /dev/sda";
      };

      percent = mkOption {
        type = types.ints.unsigned;
        default = 90;
        description = "percent when to delete, default: 90 percent";
      };

      count = mkOption {
        type = types.ints.unsigned;
        default = 5;
        description = "how much files to delete in a run";
      };

      dir = mkOption {
        type = types.path;
        description = "directory where to delete files";
      };

      logfile = mkOption {
        type = types.path;
        default = "/tmp/watermark.log";
        description =
          "path to logfile to track which files are deleted: default /tmp/watermark.log";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.timers.watermark = {
      wantedBy = [ "timers.target" ];
      partOf = [ "watermark.service" ];
      timerConfig.OnCalendar = "minutely";
    };
    systemd.services.watermark = {
      enable = true;
      description = "watermark delete service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        #!${pkgs.stdenv.shell}

        if [ $(df -P ${cfg.disk} | /run/current-system/sw/bin/awk '{ gsub("%",""); capacity = $5 }; END { print capacity }') -gt ${
          toString (cfg.percent)
        } ]
          then
            # will list all files and then delete the oldest
            find ${cfg.dir} -mtime -1 -type f | grep -v '.log' | grep -v 'dump' | grep -v 'meta.json' | sort -k 4,5 | head -n${
              toString (cfg.count)
            } | tee -a ${cfg.logfile} | xargs rm
        fi
        exit 0
      '';
    };
  };
}
