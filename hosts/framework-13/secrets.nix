{ sops-nix, ... }:
{ config, ... }:
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets."bugzilla/api-key".owner = config.users.users.michael.name;
}
