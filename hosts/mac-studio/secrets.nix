{ sops-nix, ... }:
{ config, ... }:
let
  getRunnerUser =
    runnerName:
    if (config.services.github-runners.${runnerName}.user != null) then
      config.services.github-runners.${runnerName}.user
    else
      "_github-runner";

in
{
  imports = [ sops-nix.darwinModules.sops ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets."github_runners/enterprise_helm/token".owner = getRunnerUser "enterprise-helm";
  sops.secrets."github_runners/enterprise_console/token".owner = getRunnerUser "enterprise-console";
}
