{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.userSettings = {
      "files.autoSave" = "afterDelay";
      "workbench.startupEditor" = "none";
      "workbench.colorTheme" = "Ayu Dark Bordered";
      "git.openRepositoryInParentFolders" = "never";
      "redhat.telemetry.enabled" = false;
      "rust-analyzer.inlayHints.parameterHints.enable" = false;
      "rust-analyzer.inlayHints.typeHints.enable" = false;
      "[rust]" = {
        "editor.inlayHints.enabled" = "off";
      };
      "dart.debugExternalPackageLibraries" = true;
      "dart.debugSdkLibraries" = true;
      "python.diagnostics.sourceMapsEnabled" = true;
      "window.zoomLevel" = 1;
    };
  };
}
