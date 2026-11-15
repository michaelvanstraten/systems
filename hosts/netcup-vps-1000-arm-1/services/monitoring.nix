{ config, ... }:
{
  sops.secrets."olm/env" = { };

  services.olm = {
    enable = true;
    environmentFile = config.sops.secrets."olm/env".path;
    settings."override-dns" = true;
  };

  services.resolved.enable = true;
  security.polkit.enable = true;

  services.alloy.enable = true;

  systemd.services.alloy = {
    after = [ "olm.service" ];
    wants = [ "olm.service" ];
  };
}
