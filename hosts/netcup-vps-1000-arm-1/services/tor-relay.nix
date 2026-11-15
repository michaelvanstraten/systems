let
  metricsPort = 9035;
in
{
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ContactInfo = "michael@vanstraten.de";
      Nickname = "Talus";
      ORPort = 37801;
      BandWidthRate = "128 MBytes";
      MetricsPort = "127.0.0.1:${toString metricsPort}";
      MetricsPortPolicy = "accept 127.0.0.1";
    };
  };

  services.alloy.extraConfig = ''
    prometheus.scrape "tor" {
      targets         = [{ __address__ = "127.0.0.1:${toString metricsPort}" }]
      forward_to      = [prometheus.remote_write.default.receiver]
      scrape_interval = "30s"
    }
  '';
}
