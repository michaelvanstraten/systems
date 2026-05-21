{ nixpkgs, microvm, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkIf
    mapAttrs'
    nameValuePair
    ;

  cfg = config.microvm;

  defaultGuestSystem = lib.replaceStrings [ "-darwin" ] [ "-linux" ] pkgs.stdenv.hostPlatform.system;

  evalVm =
    name: vmCfg:
    vmCfg.nixpkgs.lib.nixosSystem {
      inherit (vmCfg) system specialArgs;
      modules = [
        microvm.nixosModules.microvm
        (
          { lib, ... }:
          {
            _file = "modules/darwin/microvm.nix#vmDefaults";
            networking.hostName = lib.mkDefault name;
            microvm.vmHostPackages = lib.mkDefault pkgs;
            microvm.hypervisor = lib.mkDefault vmCfg.hypervisor;
          }
        )
      ]
      ++ lib.optional (vmCfg.config != null) vmCfg.config
      ++ vmCfg.extraModules;
    };

  vmSubmodule =
    { ... }:
    {
      options = {
        autostart = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to start this MicroVM automatically at boot via launchd.";
        };

        hypervisor = mkOption {
          type = types.enum [
            "vfkit"
            "qemu"
          ];
          default = "vfkit";
          description = ''
            Hypervisor to launch this MicroVM with.

            Only hypervisors that work on macOS are accepted. `vfkit` is the
            native Apple Virtualization Framework driver and is the default.
          '';
        };

        system = mkOption {
          type = types.str;
          default = defaultGuestSystem;
          defaultText = lib.literalExpression ''
            lib.replaceStrings [ "-darwin" ] [ "-linux" ] pkgs.stdenv.hostPlatform.system
          '';
          description = "Guest system (e.g. `aarch64-linux`).";
        };

        nixpkgs = mkOption {
          type = types.attrs;
          default = nixpkgs;
          defaultText = lib.literalExpression "nixpkgs";
          description = ''
            nixpkgs flake used to evaluate the guest configuration. Must
            expose `lib.nixosSystem`.
          '';
        };

        specialArgs = mkOption {
          type = types.attrsOf types.unspecified;
          default = { };
          description = "Extra `specialArgs` passed to the guest's `lib.evalModules`.";
        };

        config = mkOption {
          type = types.nullOr types.deferredModule;
          default = null;
          description = "NixOS module describing this MicroVM's guest configuration.";
        };

        extraModules = mkOption {
          type = types.listOf types.deferredModule;
          default = [ ];
          description = "Additional NixOS modules to merge into the guest configuration.";
        };
      };
    };
in
{
  options.microvm = {
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/microvms";
      description = ''
        Directory below which each MicroVM gets a per-VM state directory
        (used as the launchd `WorkingDirectory` and to hold auto-created
        volume images).
      '';
    };

    vms = mkOption {
      type = types.attrsOf (types.submodule vmSubmodule);
      default = { };
      description = ''
        Declarative MicroVMs to manage on this host.

        Each entry produces a `microvm-<name>` launchd daemon that runs
        the guest's `microvm-run` script built from `config`.
      '';
    };
  };

  config = mkIf (cfg.vms != { }) {
    launchd.daemons = mapAttrs' (
      name: vmCfg:
      let
        runner = (evalVm name vmCfg).config.microvm.declaredRunner;
        vmDir = "${cfg.stateDir}/${name}";
      in
      nameValuePair "microvm-${name}" {
        script = ''
          set -eu
          mkdir -p ${lib.escapeShellArg vmDir}
          cd ${lib.escapeShellArg vmDir}
          ln -sfn ${runner} current
          exec /usr/bin/script -q /dev/null ${runner}/bin/microvm-run
        '';
        serviceConfig = {
          Label = "org.microvm.${name}";
          WorkingDirectory = vmDir;
          KeepAlive = true;
          RunAtLoad = vmCfg.autostart;
          ProcessType = "Interactive";
          StandardOutPath = "${vmDir}/stdout.log";
          StandardErrorPath = "${vmDir}/stderr.log";
        };
      }
    ) cfg.vms;
  };
}
