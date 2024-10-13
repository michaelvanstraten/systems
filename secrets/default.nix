{ ... }:
{
  sops.secrets.cloudflare-api-token = {
    sopsFile = ./cluster-wide.yaml;
  };
}
