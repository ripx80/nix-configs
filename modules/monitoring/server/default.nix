/*
  todo:
      - [ ] use args
        - [ ] check all args
      - [x] seperate:
        - [x] agent and scrape settings from server
        - [ ] with https and without
      ca
        - [ ] use custom tls auth
        - [x] auth on every page
        - [x] use dns names for config

      - provisioning:
        - [ ] find a way to provisining amdin password, no default way in grafana
            - maybe keycloak?
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
        - all
        - nginx: https://nixos.wiki/wiki/Nginx#:~:text=in%20your%20firewall.-,Hardened%20setup%20with%20TLS%20and%20HSTS%20preloading,-For%20testing%20your
      - check storage time:
        - prometheus
        - loki
        - nginx access logs (logrotate?)

    optional:
      - add alertmanager, if needed for notifications
      - change: grafana to config file settings
      - check: all args working like hostIP for config in loki
      - add Grafana Alloy (grafana-agent: October 31, 2025 end of live)
      - add container around the services

      ## crate a private ca (dont use minica)
      ```
        nix-shell -p minica openssl
        mkdir ca; cd ca
        minica -ca-cert foo.pem -ca-key foo-key.pem -domains bla.foo

        # check ca cert
        openssl x509 -in foo.pem -text -noout
        # check host cert
        openssl x509 -in cert.pem -text -noout
        # check when the cert expires (2 years default)
        openssl x509 -in cert.pem -text -noout | grep "Not After"
        # check if trusted by ca
        openssl verify -verbose -CAfile ../foo.pem  bla.foo.pem

        # enable in nix
        security.pki.certificates = meta.fn.cacert;
        # or
        security.pki.certificateFiles = [ "/pathto/cert.pem" ];

      ## only openssl
      https://docs.securosys.com/openssl/osslv3/Use-Cases/self_signed_certificate
      - include bundle
      - use hostname

      ## authentication
      # grafana not have user provisioning
      # prometheus nginx basic auth
      nix-shell -p apacheHttpd
      htpasswd -c .htpasswd admin
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
          root_url = "https://ripbox.fn.internal:8010"; # helps with nginx / ws / live
          #root_url = "http://${cfg.exposedIP}:8010"; # helps with nginx / ws / live
          http_port = cfg.grafanaPort;
          http_addr = "127.0.0.1";
          protocol = "http";
          domain   = "ripbox.fn.internal";
          # serve_from_sub_path = true; then /grafana/ is possible
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

      # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "prometheus";
        }
      ];
    };
  };
}
