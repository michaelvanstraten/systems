{ config, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  address       auth-method
      local all       all                   trust
      host  all       all     127.0.0.1/32  scram-sha-256
      host  all       all     ::1/128       scram-sha-256
    '';
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
