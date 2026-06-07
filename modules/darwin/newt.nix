{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.newt;

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

  format = pkgs.formats.yaml { };
  blueprint-file = format.generate "blueprint.yaml" cfg.blueprint;

  defaultUser = "_newt";
  defaultGroup = "_newt";

  logDir = "/var/log/newt";
in
{
  options = {
    services.newt = {
      enable = lib.mkEnableOption "Newt, user space tunnel client for Pangolin";
      package = lib.mkPackageOption pkgs "fosrl-newt" { };

      settings = lib.mkOption {
        inherit type;
        default = { };
        example = {
          endpoint = "pangolin.example.com";
          id = "8yfsghj438a20ol";
        };
        description = "Settings for Newt module, see [Newt CLI docs](https://github.com/fosrl/newt?tab=readme-ov-file#cli-args) for more information.";
      };

      blueprint = lib.mkOption {
        inherit (format) type;
        default = { };
        example = {
          proxy-resources = {
            jellyfin = {
              name = "Jellyfin";
              protocol = "http";
              full-domain = "jfn.example.com";
              targets = [
                {
                  hostname = "localhost";
                  method = "http";
                  port = 8096;
                }
              ];
              auth.sso-enabled = true;
            };
          };
        };
        description = "Blueprint for declarative settings, see [Newt Blueprint docs](https://docs.pangolin.net/manage/blueprints#blueprints) for more information.";
      };

      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/newt";
        description = ''
          Directory used as `HOME` and working directory for the Newt
          launchd daemon. It is created with mode 0700 during system
          activation and owned by the configured service user/group.
        '';
      };

      user = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          User account under which the Newt daemon runs.

          If both `user` and `group` are `null`, nix-darwin will create
          an unprivileged `_newt` user and group automatically. Set this
          (and optionally `group`) to use an existing account instead.
        '';
      };

      group = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          Group under which the Newt daemon runs. See `user` for details.
        '';
      };

      environmentFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = ''
          Path to a file containing sensitive environment variables for Newt. See [Client credentials](https://docs.pangolin.net/manage/clients/credentials) for more information.
          These will overwrite anything defined in the config.
          The file should contain environment-variable assignments like:
          NEWT_ID=2ix2t8xk22ubpfy
          NEWT_SECRET=nnisrfsdfc7prqsp9ewo1dvtvci50j5uiqotez00dgap0ii2
        '';
      };

      effectiveUser = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = if cfg.user != null then cfg.user else defaultUser;
        defaultText = lib.literalMD "`user` if set, otherwise the managed `_newt` user";
        description = ''
          The user account the Newt daemon actually runs as.

          Convenience for other modules (e.g. `sops-nix`) that need to
          grant access to files consumed by the service without having
          to know whether `user` was set explicitly or left at its
          default (`null`, meaning "let nix-darwin manage `_newt`").
        '';
      };

      effectiveGroup = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default =
          if cfg.group != null then
            cfg.group
          else if cfg.user == null then
            defaultGroup
          else
            "";
        defaultText = lib.literalMD "`group` if set; `_newt` if both `user` and `group` are unset; otherwise empty";
        description = "Effective group corresponding to `effectiveUser`.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.newt.package = pkgs.fosrl-newt.overrideAttrs {
      doCheck = false;
      meta.broken = false;
    };

    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.newt.environmentFile must be provided when Newt is enabled.";
      }
      {
        assertion = (cfg.user == null && cfg.group == null) || (cfg.user != null);
        message = "`services.newt`: Either set `user` and `group` to `null` to have nix-darwin manage them, or set at least `user` explicitly.";
      }
    ];

    warnings =
      lib.optional
        (cfg.environmentFile != null && lib.hasPrefix builtins.storeDir (toString cfg.environmentFile))
        "`services.newt.environmentFile` points to a path inside the world-readable Nix store; secrets should live outside the store.";

    system.activationScripts.launchd.text = lib.mkBefore ''
      echo >&2 "setting up Newt state directory..."

      mkdir -p ${lib.escapeShellArg cfg.stateDir}
      chmod u=rwx,g=,o= ${lib.escapeShellArg cfg.stateDir}
      chown ${cfg.effectiveUser}:${cfg.effectiveGroup} ${lib.escapeShellArg cfg.stateDir}

      mkdir -p ${lib.escapeShellArg logDir}
      chmod u=rwx,g=rx,o= ${lib.escapeShellArg logDir}
      chown ${cfg.effectiveUser}:${cfg.effectiveGroup} ${lib.escapeShellArg logDir}
    '';

    launchd.daemons.newt = {
      script = ''
        set -eu

        # Load secret environment variables (e.g. NEWT_ID, NEWT_SECRET).
        set -a
        . ${lib.escapeShellArg (toString cfg.environmentFile)}
        set +a

        export HOME=${lib.escapeShellArg cfg.stateDir}
        cd ${lib.escapeShellArg cfg.stateDir}

        exec ${lib.getExe cfg.package} ${
          lib.cli.toCommandLineShellGNU { } (lib.recursiveUpdate cfg.settings { inherit blueprint-file; })
        }
      '';

      serviceConfig = {
        Label = "org.fosrl.newt";
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 10;
        ProcessType = "Background";
        UserName = cfg.effectiveUser;
        GroupName = cfg.effectiveGroup;
        WorkingDirectory = cfg.stateDir;
        StandardOutPath = "${logDir}/stdout.log";
        StandardErrorPath = "${logDir}/stderr.log";
        Umask = 63; # 0077 in octal
      };
    };

    users = lib.mkIf (cfg.user == null && cfg.group == null) {
      users.${defaultUser} = {
        createHome = false;
        description = "Newt tunnel client service user";
        gid = config.users.groups.${defaultGroup}.gid;
        home = cfg.stateDir;
        shell = "/usr/bin/false";
        uid = lib.mkDefault 534;
      };
      knownUsers = [ defaultUser ];

      groups.${defaultGroup} = {
        gid = lib.mkDefault 534;
        description = "Newt tunnel client service user group";
      };
      knownGroups = [ defaultGroup ];
    };
  };
  #
  # meta.maintainers = with lib.maintainers; [ jackr ];
}
