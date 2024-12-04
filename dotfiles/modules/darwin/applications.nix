{ mac-app-util, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.file."Applications/Home Manager Apps".enable = false;

  home.activation.link-apps =
    lib.hm.dag.entryAfter [ "linkGeneration" ]
      # bash
      ''
        global_nix_apps="${config.home.homeDirectory}/Applications/Nix Apps"

        echo "setting up $global_nix_apps..."

        ${mac-app-util.packages.${pkgs.system}.default}/bin/mac-app-util \
          sync-trampolines "$genProfilePath/home-path/Applications" \
          "$global_nix_apps"
      '';
}
