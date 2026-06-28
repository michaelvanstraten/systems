{ nixvim, ... }: { lib, config, ... }: {
  imports = [ nixvim.homeModules.nixvim ];

  programs.nixvim = {
    defaultEditor = true;

    imports = [
      ./keymap.nix
      ./options.nix
      ./performance.nix
      ./plugins/blink-cmp.nix
      ./plugins/conform.nix
      ./plugins/lazygit.nix
      ./plugins/lsp.nix
      ./plugins/mini.nix
      ./plugins/nvim-tree.nix
      ./plugins/telescope.nix
      ./plugins/treesitter.nix
    ];

    colorschemes.cyberdream = {
      enable = true;
      settings = {
        transparent = true;
      };
    };

    plugins.auto-save.enable = true;
    plugins.fidget.enable = true;
    plugins.gitsigns.enable = true;
    plugins.neoconf.enable = true;
    plugins.tmux-navigator.enable = true;
    plugins.web-devicons.enable = true;
  };

  home.shellAliases.e = lib.mkIf config.programs.nixvim.enable "nvim";
}
