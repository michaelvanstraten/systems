{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.neovim.enable {
    home.file.".config/nvim".source = ./.;

    programs.neovim = {
      defaultEditor = true;

      extraPackages = [
        pkgs.ripgrep # Needed for Telescope
        pkgs.tree-sitter
        pkgs.typst

        # Language Servers
        pkgs.clang-tools
        pkgs.lua-language-server
        pkgs.nil
        pkgs.pyright
        pkgs.rust-analyzer
        pkgs.taplo
        pkgs.texlab
        pkgs.tinymist
        pkgs.websocat # used by typst-preview.nvim
        pkgs.yaml-language-server
        pkgs.typescript-language-server
        pkgs.prettier

        # Formatters & Linters
        pkgs.harper # Grammar checker
        pkgs.nixfmt-rfc-style
        pkgs.nodejs # Needed for prettier
        pkgs.nodePackages.prettier
        pkgs.ruff
        pkgs.shfmt
        pkgs.stylua
        (pkgs.texlive.withPackages (ps: [ ps.latexindent ]))
        pkgs.typstyle
        pkgs.swift-format

        # Shell
        pkgs.fish
      ];
    };

    home.shellAliases.e = "nvim";
  };
}
