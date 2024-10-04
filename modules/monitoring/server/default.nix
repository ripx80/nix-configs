/*
  todo:
      - [x] use args
      - [x] seperate:
        - [x] agent and scrape settings from server
      ca
        - use custom tls auth: https://xeiaso.net/blog/site-to-site-wireguard-part-3-2019-04-11/
        - auth on every page
        - user + api keys
        - use dns names for config

      - provisioning:
        - amdin password, grafana
        - [x] dashboards
            - simple nodes
            - simple nginx
            - simple ssh login
            - simple wg

        - alerts: notification channel
            - discord
            - if no metrics send anymore
            - if ssh login detected
            - if cert expire
            - if nginx request rate
            - if cpu usage
            - if ram usage
            - if disk usage
            - if network usage

      - check best practices
      - check storage time:
        - prometheus
        - loki
        - nginx access logs (logrotate?)

    optional:
      - add alertmanager
      - change: grafana to config file settings
      - add Grafana Alloy (grafana-agent: October 31, 2025 end of live)
      - add container around the services
*/
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.monitoring.server;
  pkgDesc = ''
    enable full stack monitoring server
    - grafana:3010
    - prometheus:3020
    - loki:3030
    - promtail:3031
  '';
in
{
  options = {
    ripmod.monitoring.server = {
      enable = mkEnableOption "enable full stack monitoring server";

      exposedIP = mkOption {
        type = types.str;
        default = "";
        description = "IP on with nginx will running and exposed internal monitoring services";
        example = "192.168.1.1";
      };
      grafanaPort = mkOption {
        type = types.int;
        default = 3010;
        description = "grafana internal port";
        example = "192.168.1.1";
      };
      prometheusPort = mkOption {
        type = types.int;
        default = 3020;
        description = "prometheus internal port";
      };
      lokiPort = mkOption {
        type = types.int;
        default = 3030; # will not change in loki-config.yaml
        description = "loki internal port";
      };
      promtailPort = mkOption {
        type = types.int;
        default = 3031;
        description = "promtail internal port";
      };
    };
  };

  config = mkIf cfg.enable {

    # nginx reverse proxy
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      # recommendedTlsSettings = true;

      upstreams = {
        "grafana" = {
          servers = {
            "127.0.0.1:${toString cfg.grafanaPort}" = { };
          };
        };
        "prometheus" = {
          servers = {
            "127.0.0.1:${toString cfg.prometheusPort}" = { };
          };
        };
        "loki" = {
          servers = {
            "127.0.0.1:${toString cfg.lokiPort}" = { };
          };
        };
        # "promtail" = {
        #   servers = {
        #     "127.0.0.1:${toString cfg.promtailPort}" = { };
        #   };
        # };
      };

      virtualHosts.grafana = {
        locations."/" = {
          proxyPass = "http://grafana";
          proxyWebsockets = true;
        };
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8010;
          }
        ];
      };

      virtualHosts.prometheus = {
        locations."/".proxyPass = "http://prometheus";
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8020;
          }
        ];
      };

      # confirm with http://192.168.1.10:8030/loki/api/v1/status/buildinfo
      #     (or)     /config /metrics /ready
      virtualHosts.loki = {
        locations."/".proxyPass = "http://loki";
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8030;
          }
        ];
      };

      #   virtualHosts.promtail = {
      #     locations."/".proxyPass = "http://promtail";
      #     listen = [
      #       {
      #         addr = cfg.exposedIP;
      #         port = 8031;
      #       }
      #     ];
      #   };

    };

    # grafana: port 3010 (8010)
    #
    services.grafana = {
      enable = true;

      settings = {
        # WARNING: this should match nginx setup!
        # prevents "Request origin is not authorized"
        server = {
          root_url = "http://${cfg.exposedIP}:8010"; # helps with nginx / ws / live
          http_port = cfg.grafanaPort;
          http_addr = "127.0.0.1";
          protocol = "http";
          #domain   = "localhost";
        };
        analytics.reporting_enabled = false;

      };
      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString cfg.prometheusPort}";
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString cfg.lokiPort}";
            }
          ];
        };
        dashboards = {
          settings = {
            providers = [
              {
                name = "default";
                options.path = "/etc/grafana/dashboards";
              }
            ];
          };
        };
      };
    };

    environment.etc."grafana/dashboards/nodes.json" = {
      mode = "400";
      source = ./dashboards/nodes.json;
      user = "grafana";
      group = "grafana";
    };

    environment.etc."grafana/dashboards/nginx.json" = {
      mode = "400";
      source = ./dashboards/nginx.json;
      user = "grafana";
      group = "grafana";
    };



    # loki: port 3030 (8030)
    #
    services.loki = {
      enable = true;
      configFile = ./loki-config.yaml; # change port here if you use args
      #extraFlags = ["-config.expand-env"];
    };

    environment.etc."loki/config.yaml" = {
      mode = "400";
      source = ./loki-config.yaml;
      user = "loki";
      group = "loki";
    };

    # prometheus: port 3020 (8020)

    services.prometheus = {
      port = cfg.prometheusPort;
      enable = true;
      extraFlags = [ "--web.enable-remote-write-receiver" ];
      #webConfigFile = null;

      #   exporters = {
      #     node = {
      #       port = 3021;
      #       enabledCollectors = [ "systemd" ];
      #       enable = true;
      #     };
      #   };

      # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "prometheus";
          # job_name = "nodes";
          # static_configs = [
          #   { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          # ];
        }
      ];
      #   scrapeConfigs = [
      #     {
      #       job_name = "nodes";
      #       static_configs = [
      #         { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
      #       ];
      #     }
      #   ];
    };

    # promtail: port 3031 (8031)
    #
    # services.promtail = {
    #   enable = true;
    #   configuration = {
    #     server = {
    #       http_listen_port = 3031;
    #       grpc_listen_port = 0;
    #     };
    #     positions = {
    #       filename = "/tmp/positions.yaml";
    #     };
    #     clients = [ { url = "http://127.0.0.1:${toString cfg.lokiPort}/loki/api/v1/push"; } ];
    #     scrape_configs = [
    #       {
    #         job_name = "journal";
    #         journal = {
    #           max_age = "12h";
    #           labels = {
    #             job = "systemd-journal";
    #             host = "ripbox"; # # change
    #           };
    #         };
    #         relabel_configs = [
    #           {
    #             source_labels = [ "__journal__systemd_unit" ];
    #             target_label = "unit";
    #           }
    #         ];
    #       }
    #     ];
    #   };
    #   # extraFlags
    # };

  };
}
