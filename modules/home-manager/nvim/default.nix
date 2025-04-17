{ pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;
  home.packages = [
    # Core
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.ripgrep # Needed for Telescope

    # Language Servers
    pkgs.clang-tools
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.nil
    pkgs.pyright
    pkgs.rust-analyzer
    pkgs.taplo
    pkgs.texlab
    pkgs.yaml-language-server

    # Formatters & Linters
    pkgs.ltex-ls # Grammar checker
    pkgs.nixfmt-rfc-style
    pkgs.nodePackages.prettier
    pkgs.ruff
    pkgs.shfmt
    pkgs.stylua
    pkgs.texlivePackages.latexindent

    # Shell
    pkgs.fish
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.shellAliases.nv = "nvim";
}
