{ pkgs, ... }: {
  plugins.telescope = {
    enable = true;

    extensions.fzf-native.enable = true;

    keymaps = {
      "<leader><space>" = {
        action = "find_files";
        options.desc = "Lists files in your current working directory, respects .gitignore";
      };
      "?" = {
        action = "keymaps";
        options.desc = "Lists normal mode keymappings";
      };
      "gd" = {
        action = "lsp_definitions";
        options.desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope";
      };
      "gr" = {
        action = "lsp_references";
        options.desc = "Lists LSP references for word under the cursor";
      };
      "<leader>rg" = {
        action = "live_grep";
        options.desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore";
      };
      "<leader>d" = {
        action = "diagnostics";
      };
    };
  };

  extraPackages = [ pkgs.ripgrep ];
}
