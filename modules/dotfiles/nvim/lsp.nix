{ pkgs, ... }:

{
  plugins.lsp = {
    enable = true;

    onAttach = # lua
      ''
        local map = vim.keymap.set
        map("n", "ca", vim.lsp.buf.code_action, {
            buffer = bufnr,
            desc = "Selects a code action available at the current cursor position",
        })
        map("n", "cn", vim.lsp.buf.rename, {
            buffer = bufnr,
            desc = "Renames all references to the symbol under the cursor",
        })
      '';

    servers = {
      clangd.enable = true;
      harper_ls.enable = true;
      lua_ls = {
        settings = {
          Lua = {
            workspace.checkThirdParty = false;
            codeLens.enable = true;
            completion.callSnippet = "Replace";
          };
        };
      };
      nil_ls.enable = true;
      pyright.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
      taplo.enable = true;
      ts_ls.enable = true;
      yamlls.enable = true;
      gopls.enable = true;
    };
  };
}
