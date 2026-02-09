{ sops-nix, ... }:
{ config, ... }:
{
  imports = [ sops-nix.darwinModules.sops ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets."github_runners/enterprise_helm/token" = {
    owner =
      if (config.services.github-runners.enterprise-helm.user != null) then
        config.services.github-runners.enterprise-helm.user
      else
        "_github-runner";
  };
}
