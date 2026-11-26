{ sops-nix, ... }:
{ config, ... }:
{
  imports = [
    sops-nix.darwinModules.sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets."nixremote" = {
    sopsFile = ./nixremote;
    format = "binary";
  };

  sops.secrets."bugzilla/api-key".owner = config.system.primaryUser;
}
