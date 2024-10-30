{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.targets.darwin.defaultbrowser;
in
{
  options.targets.darwin.defaultbrowser = mkOption {
    type = types.nullOr types.string;
    default = null;
    description = "The default browser (HTTP handler).";
  };

  config = mkIf (cfg != null) {
    home.activation.setDefaultBroswer =
      lib.hm.dag.entryAfter [ ] # bash
        ''
          run ${lib.getExe pkgs.defaultbrowser} "${cfg}"
        '';

  };
}
