{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.olm;

  type =
    with lib.types;
    attrsOf (
      nullOr (oneOf [
        bool
        int
        float
        str
        path
        (listOf type)
      ])
    )
    // {
      description = "value coercible to CLI argument";
    };

  logDir = "/var/log/olm";
in
{
  options = {
    services.olm = {
      enable = lib.mkEnableOption "Olm, user space tunnel client for Pangolin";
      package = lib.mkPackageOption pkgs "fosrl-olm" { };

      settings = lib.mkOption {
        inherit type;
        default = { };
        example = {
          endpoint = "https://pangolin.example.com";
          id = "31frd0uzbjvp721";
          interface = "olm";
          "log-level" = "INFO";
        };
        description = ''
          Settings for the Olm CLI, see [Olm CLI docs](https://docs.pangolin.net/manage/clients/configure-clients) for more information.
          Each option corresponds to a `--flag` of the `olm` CLI (without the leading dashes).
        '';
      };

      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/olm";
        description = ''
          Directory used as `HOME` and working directory for the Olm
          launchd daemon. Created with mode 0700, owned by `root:wheel`.
        '';
      };

      environmentFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = ''
          Path to a file containing sensitive environment variables for Olm.
          See [Client credentials](https://docs.pangolin.net/manage/clients/credentials) for more information.
          The file should contain environment-variable assignments like:

          ```
          OLM_ID=31frd0uzbjvp721
          OLM_SECRET=h51mmlknrvrwv8s4r1i210azhumt6isgbpyavxodibx1k2d6
          PANGOLIN_ENDPOINT=https://pangolin.example.com
          ```

          Any of the settings documented in the Olm CLI docs may be supplied via this file as the corresponding environment variable.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.olm.environmentFile must be provided when Olm is enabled.";
      }
    ];

    warnings =
      lib.optional
        (cfg.environmentFile != null && lib.hasPrefix builtins.storeDir (toString cfg.environmentFile))
        "`services.olm.environmentFile` points to a path inside the world-readable Nix store; secrets should live outside the store.";

    system.activationScripts.launchd.text = lib.mkBefore ''
      echo >&2 "setting up Olm state directory..."

      mkdir -p ${lib.escapeShellArg cfg.stateDir}
      mkdir -p ${lib.escapeShellArg logDir}
    '';

    launchd.daemons.olm = {
      script = ''
        set -eu

        # Load secret environment variables (e.g. OLM_ID, OLM_SECRET).
        set -a
        . ${lib.escapeShellArg (toString cfg.environmentFile)}
        set +a

        export HOME=${lib.escapeShellArg cfg.stateDir}
        export SOCKET_PATH=${lib.escapeShellArg "${cfg.stateDir}/olm.sock"}
        cd ${lib.escapeShellArg cfg.stateDir}

        exec ${lib.getExe cfg.package} ${lib.cli.toCommandLineShellGNU { } cfg.settings}
      '';

      serviceConfig = {
        Label = "org.fosrl.olm";
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 10;
        ProcessType = "Background";
        WorkingDirectory = cfg.stateDir;
        StandardOutPath = "${logDir}/stdout.log";
        StandardErrorPath = "${logDir}/stderr.log";
        Umask = 63; # 0077 in octal
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ michaelvanstraten ];
}
