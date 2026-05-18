{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  vmName = "github-runners";

  vmSecretsHostPath = "/run/secrets/microvms/${vmName}";
  vmSecretsGuestPath = "/run/host-secrets";

  githubRepo = "mozilla/enterprise-console-backend";
  patSecretKey = "github-runners/pat";
  vmServiceName = "microvm@${vmName}.service";

  mkRunner = slot: rec {
    registrationName = "fxe-dxp4800plus-01-slot-${slot}";
    tokenFile = "${vmSecretsGuestPath}/runners/${registrationName}";
  };

  runners = map (n: mkRunner (toString n)) (lib.lists.range 1 5);
in
{
  microvm = {
    vms.${vmName} = {
      config = self.lib.mkModule ./configuration.nix { };
      specialArgs = {
        inherit
          runners
          vmSecretsHostPath
          vmSecretsGuestPath
          ;
      };
      restartIfChanged = true;
    };

    autostart = [ vmName ];
  };

  sops.secrets = {
    ${patSecretKey} = {
      sopsFile = ./secrets.yaml;
    };
    "microvms/${vmName}/olm/env" = {
      sopsFile = ./secrets.yaml;
      key = "olm/env";
    };
  };

  systemd.services."github-runner-registration-tokens-${vmName}" = {
    description = "Generate GitHub Actions runner registration tokens for ${vmName}";
    wantedBy = [ vmServiceName ];
    before = [ vmServiceName ];
    partOf = [ vmServiceName ];

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      curl
      jq
      coreutils
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      LoadCredential = "pat:${config.sops.secrets.${patSecretKey}.path}";
      UMask = "0077";
    };

    script = ''
      set -euo pipefail
      pat="$(cat "$CREDENTIALS_DIRECTORY/pat")"
      install -d -m 0750 "${vmSecretsHostPath}/runners"

      ${lib.concatMapStringsSep "\n" (r: ''
        echo "Requesting registration token for ${r.registrationName}..."
        token="$(
          curl --fail --silent --show-error \
            -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $pat" \
            -H "X-GitHub-Api-Version: 2026-03-10" \
            https://api.github.com/repos/${githubRepo}/actions/runners/registration-token \
            | jq --raw-output --exit-status .token
        )"
        install -m 0400 /dev/stdin "${vmSecretsHostPath}/runners/${r.registrationName}" <<<"$token"
      '') runners}
    '';
  };
}
