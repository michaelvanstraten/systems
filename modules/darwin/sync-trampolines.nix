{ mac-app-util, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.applications.sync-trampolines;
in
{
  options = {
    applications.sync-trampolines = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable to run Cachix Agent as a system service.

          Read [Cachix Deploy](https://docs.cachix.org/deploy/) documentation for more information.
        '';
      };

    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.applications.text =
      lib.mkForce
        # bash
        ''
          global_nix_apps="/Applications/Nix Apps"

          echo "setting up $global_nix_apps..."

          ourLink () {
            local link
            link=$(readlink "$1")
            [ -L "$1" ] && [ "''${link#*-}" = 'system-applications/Applications' ]
          }

          if ourLink "$global_nix_apps"; then
            rm "$global_nix_apps"
          fi

          ${mac-app-util.packages.${pkgs.system}.default}/bin/mac-app-util \
            sync-trampolines "${config.system.build.applications}/Applications" \
            "$global_nix_apps"
        '';
  };
}
