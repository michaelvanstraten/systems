{ sops-nix, ... }:
{ config, ... }:
{
  imports = [
    sops-nix.darwinModules.sops
  ];

  sops.secrets."nixremote" = {
    sopsFile = ./nixremote;
    format = "binary";
  };
}
