{ mac-app-util, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.applications;
in
{
  options.applications = {
    enableSyncTrampolines = lib.mkEnableOption "Enable usage of sync trampoline for every source app";
    enableEssentialApss = lib.mkEnableOption "Enable essental macOS apps";
  };

  config =
    {
      applications.enableSyncTrampolines = lib.mkDefault true;
      applications.enableEssentialApss = lib.mkDefault true;
    }
    // (lib.mkIf cfg.enableSyncTrampolines {
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
    })
    // (lib.mkIf cfg.enableEssentialApss {
      environment.systemPackages = [
        pkgs.monitorcontrol
        pkgs.unnaturalscrollwheels
      ];
    });
}
