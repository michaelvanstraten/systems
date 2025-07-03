{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.moz-phab;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.programs.moz-phab = {
    enable = lib.mkEnableOption "moz-phab, the Phabricator review submission/management tool";

    package = lib.mkPackageOption pkgs "moz-phab" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.moz-phab.settings = {
      updater = {
        self_auto_update = lib.mkForce false;
        # See: https://github.com/mozilla-conduit/review/blob/d4e31cb1c3d43e9dbbcadc890710739788b0fef9/mozphab/updater.py#L74
        self_last_check = -1;
      };
    };

    home.file.".moz-phab-config".source = settingsFormat.generate ".moz-phab-config" cfg.settings;
  };
}
