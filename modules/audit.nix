/*
be careful: can be very noisy
use:
    aureport -n # search for abnormalities
    ausearch -p 1 # events by process id
    auditctl -a exit,always -S chmod # check syscalls chmod
    auditctl -l # list active rules
*/
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.audit;
  pkgDesc = "audit daemon on nix";
in
{
  options = {
    ripmod.audit = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {
    boot.kernelParams = ["audit=1"];
    security.auditd.enable = true;
    security.audit.enable = true;
    security.audit.rules = [
        "-a exit,always -F arch=b64 -S execve"
        "-A exclude,always -F msgtype=SERVICE_START"
        "-A exclude,always -F msgtype=SERVICE_STOP"
        "-A exclude,always -F msgtype=BPF"
        "-A exclude,always -F exe=/usr/bin/sudo"
    ];

    services.logrotate.settings = {
        # audit daemon
        "/var/log/audit/audit.log" = {
            frequency = "daily";
            rotate = 3;
            compress = true;
        };
    };
  };
}


