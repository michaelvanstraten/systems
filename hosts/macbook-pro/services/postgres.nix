{ config, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };

  system.activationScripts.preActivation = {
    enable = true;
    text =
      let
        dataDir = config.services.postgresql.dataDir;
      in
      ''
        if [ ! -d "${dataDir}" ]; then
          echo "creating PostgreSQL data directory..."
          sudo mkdir -m 750 -p "${dataDir}"
          chown -R ${config.system.primaryUser}:staff "${dataDir}"
        fi
      '';
  };

  services.postgresql.initdbArgs = [
    "-U ${config.system.primaryUser}"
  ];

  launchd.user.agents.postgresql.serviceConfig = {
    StandardErrorPath = "/tmp/postgres.error.log";
    StandardOutPath = "/tmp/postgres.log";
  };
}
