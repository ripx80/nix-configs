{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.monitoring;
  pkgDesc = "enable grafana agent monitoring";
in
{
  options = {
    ripmod.monitoring = {
      enable = mkEnableOption "enable grafana agent monitoring service.";
      env = mkOption {
        type = types.path;
        description = ''
          path to environment file with the access token to the monitoring system.
          if you use agenix add this to your secrets:

          # agent monitoring
          age.secrets."services/monitoring/agent" = {
              file = secrets + /secrets/services/monitoring/agent.age;
              path = "/run/services/monitoring/agent.env";
          };
        '';
        example = "config.age.secrets." services/monitoring/agent ".path";
      };
      agent = mkOption {
        type = types.path;
        description = "path to agent.yaml config file";
        default = ./agent.yaml;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ grafana-agent ];

    users = {
      groups.grafana = { };
      users.grafana = {
        isSystemUser = true;
        group = "grafana";
        extraGroups = [
          "systemd-journal"
          "nginx"
        ]; # add nginx or other daemons here
        # need access to
        # /tmp/wal
        # /tmp/positions.yaml
        # /var/log/*log
        # /var/log/journal
        # /etc/grafana-agent/agent.yaml
        # other logs to include
      };
    };

    environment.etc."grafana-agent/agent.yaml" = {
      mode = "400";
      source = cfg.agent;
      user = "grafana";
      group = "grafana";
    };

    systemd.services.grafana-agent = {
      enable = true;
      description = "grafana-agent service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        HOSTNAME = config.networking.hostName;
      };
      serviceConfig = {
        User = "grafana";
        Restart = "always";
        ExecStart = ''${pkgs.grafana-agent}/bin/grafana-agent --config.file=/etc/grafana-agent/agent.yaml --config.expand-env --server.http.address="127.0.0.1:9100"'';
        EnvironmentFile = cfg.env;
      };
    };
  };
}
