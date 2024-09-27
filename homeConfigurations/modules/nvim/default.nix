{ inputs, pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;

  home.packages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];
}
