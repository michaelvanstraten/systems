{ self, ... }:
{ lib, ... }:
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
    autostart = true;
    hypervisor = "vfkit";
    specialArgs = {
      inherit vmSecretsHostPath;
    };
    config = self.lib.mkModule ./configuration.nix { };
  };
}
