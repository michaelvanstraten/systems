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

        ${mac-app-util.packages.${pkgs.system}.default}/bin/mac-app-util \
          sync-trampolines "${config.system.build.applications}/Applications" \
          "$global_nix_apps"
      '';
}
