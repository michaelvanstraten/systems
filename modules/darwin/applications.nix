{ mac-app-util, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.monitorcontrol
    pkgs.unnaturalscrollwheels
  ];
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
}
