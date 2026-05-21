{ self, ... }:
{ ... }:
let
  vmName = "buildkit";
  vmSecretsHostPath = "/run/secrets/microvms/${vmName}";
in
{
  sops.secrets."microvms/${vmName}/newt/env" = {
    sopsFile = ./secrets.yaml;
    key = "newt/env";
  };

  microvm.vms.buildkit = {
    config = self.lib.mkModule ./configuration.nix { };
    specialArgs = { inherit vmSecretsHostPath; };
  };

  microvm.autostart = [ "buildkit" ];
}
