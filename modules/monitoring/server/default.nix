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

    expose:
    - grafana:8010
    - prometheus:8020
    - loki:8030
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
        default = "/etc/ssl/cert.pem";
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
    # host certificate key is owned by ca group
    # htpasswd file is owned by ca web group
    users.users.nginx.extraGroups = [
      "ca"
      "web"
    ];

    # nginx reverse proxy
    services.nginx = {
      enable = true;
      #package = pkgs.nginxStable.override { openssl = pkgs.boringssl; };
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
      #sslCiphers = "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305";

      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        # add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";

        # disable version leaking
        # server_tokens off; # already set by recommended

        # send_file func to enable ktls
        # sendfile on;
      '';

      virtualHosts.grafana = {
        onlySSL = true;
        sslCertificateKey = cfg.certKey;
        sslCertificate = cfg.cert;
        sslTrustedCertificate = cfg.cert; # "/etc/ssl/certs/ca-bundle.crt";
        kTLS = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.grafanaPort}";
          proxyWebsockets = true;
          # basicAuthFile = cfg.htpasswd;
        };
        listen = [
          {
            addr = cfg.exposedIP;
            port = 8010;
            ssl = true;
          }
        ];

        extraConfig = ''
          # required when the target is also TLS server with multiple hosts
          #"proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          #"proxy_pass_header Authorization;"

          # tls
          ssl_stapling off;
          ssl_stapling_verify off;
          ssl_protocols TLSv1.3;

          # kernel tls (ktls)
          # ssl_conf_command Options KTLS;
        '';
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

      # confirm with http://<ip>:8030/loki/api/v1/status/buildinfo
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
    services.grafana = {
      enable = true;

      settings = {
        # WARNING: this should match nginx setup!
        # prevents "Request origin is not authorized"
        server = {
          root_url = "https://${cfg.fqdn}:8010"; # helps with nginx / ws / live
          http_port = cfg.grafanaPort;
          http_addr = "127.0.0.1";
          protocol = "http";
          domain = cfg.fqdn;
          # serve_from_sub_path = true; then /grafana/ is possible
        };
        security = {
          admin_user = "admin";
          # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#variable-expansion
          # admin password:
          # by file, not working
          # admin_password = "$__file{${cfg.grafanaPw}}";
          # by env var
          # will be overwritten by env var: GF_SECURITY_ADMIN_PASSWORD

          cookie_secure = true;
          disable_gravatar = true; # disable icon fetch
          cookie_samesite = "strict";
          #content_security_policy = true;
          #content_security_policy_template = ''
          #script-src 'self' 'unsafe-eval' 'unsafe-inline' 'strict-dynamic' $NONCE;object-src 'none';font-src 'self';style-src 'self' 'unsafe-inline' blob:;img-src * data:;base-uri 'self';connect-src 'self' grafana.com ws://$ROOT_PATH wss://$ROOT_PATH;manifest-src 'self';media-src 'none';form-action 'self';
          #'';
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
        alerting = {
          rules.path = "/etc/grafana/alertrules.json";
          # templates.path = "/etc/grafana/discord-template.tpl";
          policies.path = "/etc/grafana/policies.json";

          contactPoints.settings = {
            apiVersion = 1;
            contactPoints = [
              {
                orgId = 1;
                name = "frostbot-discord";
                receivers = [
                  {
                    uid = "ce1563ndhgni9c";
                    type = "discord";
                    settings = {
                      url = "\${DISCORD_WEBHOOK}";
                      title = "frostbot screams";
                      message = "{{ template \"default.title\" .}}";
                      use_discord_username = true;
                      disableResolveMessage = true; # todo: not working
                    };
                  }
                ];
              }
            ];
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

    environment.etc."grafana/policies.json" = {
      mode = "400";
      source = ./policies.json;
      user = "grafana";
      group = "grafana";
    };

    environment.etc."grafana/alertrules.json" = {
      mode = "400";
      source = ./alertrules.json;
      user = "grafana";
      group = "grafana";
    };

    # loki: port 3030 (8030)
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;
        server.http_listen_port = cfg.lokiPort;
        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/var/lib/loki";
        };

        schema_config = {
          configs = [
            {
              from = "2020-07-31";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
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

    # prometheus: port 3020 (8020)
    services.prometheus = {
      port = cfg.prometheusPort;
      enable = true;
      extraFlags = [ "--web.enable-remote-write-receiver" ];
      # ingest the published nodes
      scrapeConfigs = [ { job_name = "prometheus"; } ];
    };
  };
}
