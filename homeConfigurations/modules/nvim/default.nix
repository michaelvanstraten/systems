{ neovim-nightly-overlay, pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;

  home.packages = [ neovim-nightly-overlay.packages.${pkgs.system}.default ];
}
