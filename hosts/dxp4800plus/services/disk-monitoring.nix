{ config, ... }:
let
  smartctlPort = config.services.prometheus.exporters.smartctl.port;
  zfsPort = config.services.prometheus.exporters.zfs.port;
in
{
  services.prometheus.exporters = {
    smartctl = {
      enable = true;
      maxInterval = "30s";
    };

    zfs.enable = true;
  };

  services.smartd = {
    enable = true;
    autodetect = true;
    defaults.monitored = builtins.concatStringsSep " " [
      "-a" # monitor all SMART attributes
      "-o on" # enable automatic offline data collection
      "-S on" # enable attribute autosave
      "-n standby,q" # don't spin up sleeping disks just to poll them
      "-s (S/../.././02|L/../../6/03)" # short test daily 02:00, long test Sat 03:00
      "-W 4,45,55" # temperature: 4C change / 45C info / 55C critical
    ];
  };

  services.alloy.extraConfig = ''
    prometheus.scrape "smartctl" {
      targets         = [{ __address__ = "127.0.0.1:${toString smartctlPort}" }]
      forward_to      = [prometheus.remote_write.default.receiver]
      scrape_interval = "30s"
    }

    prometheus.scrape "zfs" {
      targets         = [{ __address__ = "127.0.0.1:${toString zfsPort}" }]
      forward_to      = [prometheus.remote_write.default.receiver]
      scrape_interval = "30s"
    }
  '';
}
