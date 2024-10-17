/*
  todo:
      - provisioning: 07.11
        - [x] find a way to provisining amdin password, no default way in grafana
        - [x] dashboards
            - simple nodes
            - simple nginx
            - simple ssh login
            - simple wg
        - check tls
            - ./tls-scan -c search.yahoo.com --all --pretty
            - sslmap
            - sslscan/2  nix-shell -p sslscan
            - tslx

        - alerts: notification channel
            - [x] discord
                - make alerting optional
            - [ ] template
            - if no metrics send anymore
            - if ssh login detected
            - if cert expire
            - if nginx request rate
            - if cpu usage
            - if ram usage
            - if disk usage
            - if network usage
      - check storage time:
        - prometheus, default 14 days
        - loki, 62 days
        - nginx access logs (logrotate?)

    optional:
      - add Grafana Alloy (grafana-agent: October 31, 2025 end of live)
      - add container around the services

      ## crate a private ca

        # enable in nix
        security.pki.certificates = meta.fn.cacert;
        # or
        security.pki.certificateFiles = [ "/pathto/cert.pem" ];

      ## only openssl
        # ca:
        openssl genrsa -out rootCA.key 4096
        openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt

        # server certificate and key
        # key
        openssl genrsa -out ripnote.key 4096
        # request
        openssl req -new -sha256 -key ripnote.key -subj "/O=frostnet, Inc./CN=ripnote.fn.internal" -out ripnote.csr
        # verify request
        openssl req -in ripnote.csr -noout -text
        # generate cert
        openssl x509 -req -in ripnote.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out ripnote.crt -days 3650 -sha256
        # verify cert
        openssl x509 -in mydomain.com.crt -text -noout
        openssl verify -verbose -CAfile rootCA.crt ripnote.crt


      ## authentication
      # grafana not have user provisioning, but you can set with
      # services.grafana.settings.security.admin_password a password.
      # this will leaked in the /nix/store.
      # prometheus nginx grafana basic auth
      nix-shell -p apacheHttpd
      htpasswd -c .htpasswd admin
      basic auth sens on every request the auth. its not optimal but better than nothing. use OAuth instead.

      ## check ssl
      nix-shell -p sslscan
      sslscan ripnote.fn.internal:8010
      ```
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
      certKey = mkOption {
        type = types.path;
        default = null;
        description = "certificate key file in pem format";
      };
      cert = mkOption {
        type = types.path;
        default = null;
        description = "certificate file in pem format";
      };
       htpasswd = mkOption {
        type = types.path;
        default = null;
        description = "htpasswd file";
      };
      fqdn = mkOption {
        type = types.str;
        default = "localhost";
        description = "set fqdn domain name";
      };
      env = mkOption {
        type = types.path;
        default = null;
        description = "webhook for discord alerting";
      };
    };
  };

  config = mkIf cfg.enable {

    # nginx reverse proxy
    services.nginx = {
      enable = true;
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      virtualHosts.grafana = {
        onlySSL = true;
        sslCertificateKey = cfg.certKey;
        sslCertificate = cfg.cert;
        sslTrustedCertificate = "/etc/ssl/certs/ca-bundle.crt";

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.grafanaPort}";
          proxyWebsockets = true;
          basicAuthFile = cfg.htpasswd;
        };
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8010;
            ssl = true;
          }
        ];
    #     extraConfig =
    #       # required when the target is also TLS server with multiple hosts
    #       "proxy_ssl_server_name on;" +
    #       # required when the server wants to use HTTP Authentication
    #       "proxy_pass_header Authorization;"
    #       ;
       };

      virtualHosts.prometheus = {
        onlySSL = true;
        sslCertificateKey = cfg.certKey;
        sslCertificate = cfg.cert;
        sslTrustedCertificate = "/etc/ssl/certs/ca-bundle.crt";

        locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.prometheusPort}";
            basicAuthFile = cfg.htpasswd;
        };

        listen = [
          {
            addr = cfg.exposedIP;
            port = 8020;
            ssl = true;
          }
        ];
      };

      # confirm with http://192.168.1.10:8030/loki/api/v1/status/buildinfo
      #     (or)     /config /metrics /ready
      virtualHosts.loki = {
        onlySSL = true;
        sslCertificateKey = cfg.certKey;
        sslCertificate = cfg.cert;
        sslTrustedCertificate = "/etc/ssl/certs/ca-bundle.crt";

        locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.lokiPort}";
            basicAuthFile = cfg.htpasswd;
        };
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8030;
            ssl = true;
          }
        ];
      };
    };

    # grafana: port 3010 (8010)
    #
    services.grafana = {
      enable = true;

      settings = {
        # WARNING: this should match nginx setup!
        # prevents "Request origin is not authorized"
        server = {
          root_url = "https://${cfg.fqdn}:8010"; # helps with nginx / ws / live
          #root_url = "http://${cfg.exposedIP}:8010"; # helps with nginx / ws / live
          http_port = cfg.grafanaPort;
          http_addr = "127.0.0.1";
          protocol = "http";
          domain   = cfg.fqdn;
          # serve_from_sub_path = true; then /grafana/ is possible
        };
        analytics.reporting_enabled = false;
         #security.admin_password # only string allowed so pw is in store, use basic auth

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
        alerting = {
            #rules.settings
            #templates.settings
            #policies.settings
            contactPoints.settings = {
                apiVersion = 1;
                contactPoints = [{
                    orgId = 1;
                    name = "frostbot-discord";
                    receivers = [{
                    uid = "ce1563ndhgni9c";
                    type = "discord";
                    settings = {
                        url = "\${DISCORD_WEBHOOK}"; #cfg.discordWebhook;
                        use_discord_username = true;
                        disableResolveMessage = true;
                    };
                    }];
                }];
            };
        };
        #notifiers = [];
      };

    };
    systemd.services.grafana.serviceConfig.EnvironmentFile = cfg.env;

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
      #configFile = ./loki-config.yaml; # change port here if you use args
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;
        server.http_listen_port = cfg.lokiPort;
        common = {
            ring = {
                instance_addr = "127.0.0.1";
                kvstore.store =  "inmemory";
            };
            replication_factor = 1;
            path_prefix = "/var/lib/loki";
        };

        schema_config = {
            configs = [{
                from = "2020-07-31";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                    prefix = "index_";
                    period = "24h";
                };
            }];
        };
        storage_config = {
            filesystem.directory = "/var/lib/loki/chunks";
        };
        limits_config = {
            retention_period = "1488h"; # 62 days
            reject_old_samples = true;
            reject_old_samples_max_age = "168h"; # 7 days
        };
        compactor = {
            working_directory = "/var/lib/loki/retention";
            compaction_interval = "10m";
            retention_enabled = true;
            retention_delete_delay = "2h";
            retention_delete_worker_count = 150;
            delete_request_store = "filesystem";
        };
      };
    };

    # environment.etc."loki/config.yaml" = {
    #   mode = "400";
    #   source = ./loki-config.yaml;
    #   user = "loki";
    #   group = "loki";
    # };

    # prometheus: port 3020 (8020)

    services.prometheus = {
      port = cfg.prometheusPort;
      enable = true;
      extraFlags = [ "--web.enable-remote-write-receiver" ];
       # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "prometheus";
        }
      ];
    };
  };
}
