{ sops-nix, ... }:
{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  keyFile = "/var/lib/sops-nix/key.txt";
  sopsModule = if isDarwin then sops-nix.darwinModules.sops else sops-nix.nixosModules.sops;
in
{
  imports = [ sopsModule ];

  sops = {
    age = {
      inherit keyFile;
      generateKey = lib.mkDefault true;
      sshKeyPaths = [ ];
    };

    gnupg.sshKeyPaths = [ ];
  };
}
