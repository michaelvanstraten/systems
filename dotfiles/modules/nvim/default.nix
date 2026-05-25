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
        pkgs.basedpyright
        pkgs.rust-analyzer
        pkgs.taplo
        pkgs.tinymist
        pkgs.websocat # used by typst-preview.nvim
        pkgs.yaml-language-server
        pkgs.typescript-language-server
        pkgs.prettier

        # Formatters & Linters
        pkgs.harper # Grammar checker
        pkgs.nixfmt
        pkgs.nodejs # Needed for prettier
        pkgs.prettier
        pkgs.ruff
        pkgs.shfmt
        pkgs.stylua
        pkgs.typstyle
      ];

      withPython3 = false;
      withRuby = false;
    };

    home.shellAliases.e = "nvim";
  };
}
