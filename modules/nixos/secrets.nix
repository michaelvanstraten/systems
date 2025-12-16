{ sops-nix, ... }:
{ config, lib, ... }:
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  config = lib.mkMerge [
    {
      sops.defaultSopsFile = ../../secrets.yaml;
    }
    (lib.mkIf config.services.tailscale.enable {
      sops.secrets."tailscale/oauth_client_secret" = { };
    })
  ];
}
