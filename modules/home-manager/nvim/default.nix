{ pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;
  home.packages = [
    pkgs.neovim
    # Additional packages
    pkgs.ltex-ls # Grammar checker
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.ripgrep # Needed for Telescope
    pkgs.stylua
    pkgs.tree-sitter
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.shellAliases.nv = "nvim";
}
