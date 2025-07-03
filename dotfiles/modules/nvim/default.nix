{ nil_ls, ... }:
{ pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;
  home.packages = [
    # Core
    pkgs.neovim
    pkgs.ripgrep # Needed for Telescope
    pkgs.tree-sitter
    pkgs.typst

    # Language Servers
    pkgs.clang-tools
    pkgs.lua-language-server
    (nil_ls.packages.${pkgs.system}.nil.override {
      doCheck = false;
    })
    pkgs.pyright
    pkgs.rust-analyzer
    pkgs.taplo
    pkgs.texlab
    pkgs.yaml-language-server
    pkgs.tinymist
    pkgs.websocat # used by typst-preview.nvim

    # Formatters & Linters
    pkgs.harper # Grammar checker
    pkgs.nixfmt-rfc-style
    pkgs.nodejs # Needed for prettier
    pkgs.nodePackages.prettier
    pkgs.ruff
    pkgs.shfmt
    pkgs.stylua
    pkgs.texlivePackages.latexindent
    (pkgs.texlive.withPackages (ps: [ ps.latexindent ]))
    pkgs.typstyle
    pkgs.swift-format

    # Shell
    pkgs.fish
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.shellAliases.e = "nvim";
}
