{ lib, options, ... }:
let
  keyFile = "/var/lib/sops-nix/key.txt";
in
{
  config = lib.optionalAttrs (options ? sops) {
    sops = {
      age = {
        inherit keyFile;
        generateKey = lib.mkDefault true;
        sshKeyPaths = [ ];
      };
      gnupg.sshKeyPaths = [ ];
    };
  };
}
