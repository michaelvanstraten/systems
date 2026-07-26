{ config, ... }:
let
  containerIp = "10.100.0.11";
  cfg = config.containers.navidrome.config;
  mediaDir = "/srv/media";
  mediaGid = 1500;
in
{
  services.newt.blueprint = {
    private-resources = {
      navidrome = {
        name = "Navidrome";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.navidrome.settings.Port;
        full-domain = "navidrome.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.navidrome = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      ${mediaDir} = {
        hostPath = "/tank/media";
        isReadOnly = true;
      };

      "/var/lib/navidrome" = {
        hostPath = "/tank/appdata/navidrome";
        isReadOnly = false;
      };
    };

    config = {
      users.groups.media.gid = mediaGid;

      users.users.navidrome.extraGroups = [ "media" ];

      services.navidrome = {
        enable = true;
        openFirewall = true;
        settings = {
          Address = "0.0.0.0";
          MusicFolder = "${mediaDir}/Music";
        };
      };
    };
  };
}
