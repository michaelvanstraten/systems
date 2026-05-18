# TODO: Upstream with once I have worked out the kinks
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

    boot.kernelModules = [ "tun" ];

    # Olm sets per-link DNS on its WireGuard interface by calling
    # org.freedesktop.resolve1.Link.SetDNS over D-Bus. systemd-resolved gates
    # those methods through polkit, which by default denies non-root callers.
    # Allow the unit's DynamicUser (named after the unit, i.e. "olm") to make
    # the calls it needs to manage DNS for its own link.
    #
    # TODO: Find an alternative to enabling and configuring polkit
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        var allowed = [
          "org.freedesktop.resolve1.set-dns-servers",
          "org.freedesktop.resolve1.set-domains",
          "org.freedesktop.resolve1.set-default-route",
          "org.freedesktop.resolve1.set-dnssec",
          "org.freedesktop.resolve1.set-dns-over-tls",
          "org.freedesktop.resolve1.revert"
        ];
        if (subject.user == "olm" && allowed.indexOf(action.id) >= 0) {
          return polkit.Result.YES;
        }
      });
    '';

    systemd.services.olm = {
      description = "Olm, user space tunnel client for Pangolin";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        HOME = "/var/lib/private/olm";
        SOCKET_PATH = "/run/olm/olm.sock";
      };
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} ${lib.cli.toCommandLineShellGNU { } cfg.settings}";
        DynamicUser = true;
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        RuntimeDirectory = [
          "olm"
          "wireguard"
        ];
        RuntimeDirectoryMode = "0700";
        StateDirectory = "olm";
        StateDirectoryMode = "0700";
        Restart = "always";
        RestartSec = "10s";
        EnvironmentFile = cfg.environmentFile;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = "disconnected";
        PrivateDevices = false;
        DeviceAllow = [ "/dev/net/tun rw" ];
        PrivateUsers = false;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
        ProtectProc = "noaccess";
        ProtectHostname = true;
        RemoveIPC = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];
        CapabilityBoundingSet = [
          "~CAP_BLOCK_SUSPEND"
          "~CAP_BPF"
          "~CAP_CHOWN"
          "~CAP_MKNOD"
          "~CAP_NET_RAW"
          "~CAP_PERFMON"
          "~CAP_SYS_BOOT"
          "~CAP_SYS_CHROOT"
          "~CAP_SYS_MODULE"
          "~CAP_SYS_NICE"
          "~CAP_SYS_PACCT"
          "~CAP_SYS_PTRACE"
          "~CAP_SYS_TIME"
          "~CAP_SYS_TTY_CONFIG"
          "~CAP_SYSLOG"
          "~CAP_WAKE_ALARM"
        ];
        SystemCallFilter = [
          "~@aio:EPERM"
          "~@chown:EPERM"
          "~@clock:EPERM"
          "~@cpu-emulation:EPERM"
          "~@debug:EPERM"
          "~@keyring:EPERM"
          "~@memlock:EPERM"
          "~@module:EPERM"
          "~@mount:EPERM"
          "~@obsolete:EPERM"
          "~@pkey:EPERM"
          "~@privileged:EPERM"
          "~@raw-io:EPERM"
          "~@reboot:EPERM"
          "~@resources:EPERM"
          "~@sandbox:EPERM"
          "~@setuid:EPERM"
          "~@swap:EPERM"
          "~@sync:EPERM"
          "~@timer:EPERM"
        ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ michaelvanstraten ];
}
