{ sops-nix, ... }:
_: {
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    secrets."tailscale/oauth_client_secret" = { };
  };
}
