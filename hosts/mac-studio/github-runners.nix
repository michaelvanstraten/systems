{ config, lib, ... }:
let
  getRunnerUser =
    runnerName:
    if (config.services.github-runners.${runnerName}.user != null) then
      config.services.github-runners.${runnerName}.user
    else
      "_github-runner";

in
lib.mkMerge (
  [
    {
      services.github-runners."enterprise-helm" = {
        enable = true;
        url = "https://github.com/mozilla/enterprise-helm";
        tokenFile = config.sops.secrets."github_runners/enterprise_helm/token".path;
        name = config.networking.hostName;
      };
      sops.secrets."github_runners/enterprise_helm/token".owner = getRunnerUser "enterprise-helm";
    }
  ]
  ++ (map (
    num:
    let
      runnerName = "enterprise-console-${num}";
      tokenSecret = "github_runners/enterprise_console_${num}/token";
    in
    {
      services.github-runners.${runnerName} = {
        enable = true;
        replace = true;
        url = "https://github.com/mozilla/enterprise-console-backend";
        tokenFile = config.sops.secrets.${tokenSecret}.path;
        name = "${config.networking.hostName}-slot-${num}";
      };
      sops.secrets.${tokenSecret}.owner = getRunnerUser runnerName;
    }
  ) (map builtins.toString (lib.lists.range 1 5)))
)
