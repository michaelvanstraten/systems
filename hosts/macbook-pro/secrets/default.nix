{ sops-nix, ... }:
{
  imports = [ sops-nix.darwinModules.sops ];

  sops = {
    secrets.nixremote-ssh-key = {
      sopsFile = ./nixremote-ssh-key;
      format = "binary";
    };
  };
}
