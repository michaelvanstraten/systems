{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.buildkitd;

  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "buildkitd.toml" cfg.settings;
in
{
  options.services.buildkitd = {
    enable = lib.mkEnableOption "the buildkitd build daemon";

    package = lib.mkPackageOption pkgs "buildkit" { };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          grpc.address = [ "unix:///run/buildkit/buildkitd.sock" ];
          worker.oci.enabled = true;
          worker.containerd.enabled = false;
        }
      '';
      description = ''
        Configuration written verbatim to `buildkitd.toml` and passed to
        buildkitd via `--config`. See
        <https://github.com/moby/buildkit/blob/master/docs/buildkitd.toml.md>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.buildkit = { };

    systemd.services.buildkitd = {
      description = "BuildKit build daemon";
      documentation = [ "https://github.com/moby/buildkit" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      path = [
        pkgs.runc
        pkgs.git
      ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/buildkitd --config ${configFile}";
        Restart = "on-failure";
        RestartSec = "2s";
        Group = "buildkit";
        StateDirectory = "buildkit";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "buildkit";
        RuntimeDirectoryMode = "0750";
        NoNewPrivileges = false;
      };
    };
  };
}
