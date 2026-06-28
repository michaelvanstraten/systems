{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.alloy;

  hostName = config.networking.hostName;

  baseConfig = ''
    prometheus.exporter.unix "local_system" { }

    prometheus.scrape "node" {
      targets         = prometheus.exporter.unix.local_system.targets
      forward_to      = [prometheus.remote_write.default.receiver]
      scrape_interval = "15s"
    }

    prometheus.remote_write "default" {
      external_labels = {
        host = "${hostName}",
      }

      endpoint {
        url = "${cfg.prometheusUrl}"
      }
    }

    loki.source.journal "journal" {
      path          = "/var/log/journal"
      forward_to    = [loki.write.default.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {
        job = "systemd-journal",
      }
    }

    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "service_name"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "host"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "hostname"
      }

      rule {
        source_labels = ["__journal__machine_id"]
        target_label  = "machine_id"
      }

      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }

    loki.write "default" {
      endpoint {
        url = "${cfg.lokiUrl}"
      }
    }
  '';

  configFile = pkgs.writeText "config.alloy" (
    baseConfig + lib.optionalString (cfg.extraConfig != "") ("\n" + cfg.extraConfig)
  );
in
{
  options.services.alloy = {
    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://loki.monitoring.vanstraten.cloud/loki/api/v1/push";
      description = "Loki push endpoint logs are forwarded to.";
    };

    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://prometheus.monitoring.vanstraten.cloud/api/v1/write";
      description = "Prometheus remote-write endpoint metrics are forwarded to.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra Alloy configuration appended verbatim to the generated config.

        Use this to declare additional components (exporters, scrapes, log
        sources, ...) on a per-host basis. Forward metrics to
        `prometheus.remote_write.default.receiver` and logs to
        `loki.write.default.receiver` to reuse the shared endpoints.
      '';
      example = lib.literalExpression ''
        '''
          prometheus.exporter.self "alloy" { }

          prometheus.scrape "alloy" {
            targets    = prometheus.exporter.self.alloy.targets
            forward_to = [prometheus.remote_write.default.receiver]
          }
        '''
      '';
    };
  };

  config = {
    services.alloy.configPath = lib.mkIf cfg.enable configFile;

    systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkIf cfg.enable [
      "systemd-journal"
    ];
  };
}
