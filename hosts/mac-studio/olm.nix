{ config, ... }:
{
  sops.secrets."olm/env" = { };

  services.olm = {
    enable = true;
    environmentFile = config.sops.secrets."olm/env".path;
    settings."override-dns" = true;
  };
}
