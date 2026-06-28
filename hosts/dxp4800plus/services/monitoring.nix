{ config, ... }:
let
  containerIp = "10.100.0.9";

  grafana_domain = "grafana.monitoring.vanstraten.cloud";
  grafana_http_port = 3000;
  loki_domain = "loki.monitoring.vanstraten.cloud";
  loki_http_port = 3100;
  prometheus_domain = "prometheus.monitoring.vanstraten.cloud";
  prometheus_port = 3200;
in
{
  services.newt.blueprint = {
    private-resources = {
      grafana = {
        name = "Grafana";
        mode = "http";
        destination = containerIp;
        destination-port = grafana_http_port;
        full-domain = grafana_domain;
        ssl = true;
        scheme = "http";
      };
      loki = {
        name = "Grafana Loki";
        mode = "http";
        destination = containerIp;
        destination-port = loki_http_port;
        full-domain = loki_domain;
        ssl = true;
        scheme = "http";
      };
      prometheus = {
        name = "Prometheus";
        mode = "http";
        destination = containerIp;
        destination-port = prometheus_port;
        full-domain = prometheus_domain;
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.monitoring =
    let
      lokiDataDir = "/var/lib/loki";
    in
    {
      localAddress = "${containerIp}/24";

      bindMounts = {
        ${config.containers.monitoring.config.services.grafana.dataDir} = {
          hostPath = "/tank/appdata/monitoring/grafana";
          isReadOnly = false;
        };
        "/var/lib/${config.containers.monitoring.config.services.prometheus.stateDir}" = {
          hostPath = "/tank/appdata/monitoring/prometheus";
          isReadOnly = false;
        };
        ${lokiDataDir} = {
          hostPath = "/tank/appdata/monitoring/loki";
          isReadOnly = false;
        };
      };

      config = {
        services = {
          grafana = {
            enable = true;
            settings = {
              server = {
                http_addr = "0.0.0.0";
                http_port = grafana_http_port;
                enforce_domain = true;
                enable_gzip = true;
                domain = grafana_domain;
              };
              security.secret_key = "f0ffc581602dad869f78d08d6b9614e66cd51321bc0aadc2e4de62785174328e";
            };
            provision = {
              enable = true;
              datasources.settings.datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  uid = "prometheus";
                  access = "proxy";
                  url = "http://localhost:${toString prometheus_port}";
                  isDefault = true;
                }
                {
                  name = "Loki";
                  type = "loki";
                  uid = "loki";
                  access = "proxy";
                  url = "http://localhost:${toString loki_http_port}";
                }
              ];
            };
            openFirewall = true;
          };

          loki = {
            enable = true;
            configuration = {
              auth_enabled = false;
              server.http_listen_port = 3100;

              common = {
                ring = {
                  instance_addr = "127.0.0.1";
                  kvstore = {
                    store = "inmemory";
                  };
                };
                replication_factor = 1;
                path_prefix = lokiDataDir;
              };

              schema_config = {
                configs = [
                  {
                    from = "2020-05-15";
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
                filesystem = {
                  directory = "${lokiDataDir}/chunks";
                };
              };
            };
          };

          prometheus = {
            port = prometheus_port;
            enable = true;
            extraFlags = [ "--web.enable-remote-write-receiver" ];
          };
        };

        networking.firewall.allowedTCPPorts = [
          loki_http_port
          prometheus_port
        ];
      };
    };
}
