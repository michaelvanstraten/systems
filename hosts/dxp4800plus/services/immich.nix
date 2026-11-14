{ config, ... }:
let
  containerIp = "10.100.0.13";
  cfg = config.containers.immich.config;
  fqdn = "immich.vanstraten.cloud";
in
{
  services.newt.blueprint = {
    private-resources = {
      immich = {
        name = "Immich";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.immich.port;
        full-domain = fqdn;
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.immich = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/var/lib/immich" = {
        hostPath = "/tank/appdata/immich";
        isReadOnly = false;
      };
    };

    config = {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        openFirewall = true;
        mediaLocation = "/var/lib/immich";
      };
    };
  };
}
