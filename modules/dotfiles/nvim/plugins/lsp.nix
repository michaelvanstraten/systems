{
  plugins.lspconfig.enable = true;

  lsp = {
    keymaps = [
      {
        key = "ca";
        lspBufAction = "code_action";
        options.desc = "Selects a code action available at the current cursor position";
      }
      {
        key = "cn";
        lspBufAction = "rename";
        options.desc = "Renames all references to the symbol under the cursor";
      }
    ];

    servers = {
      clangd.enable = true;
      harper_ls.enable = true;
      lua_ls = {
        config = {
          Lua = {
            workspace.checkThirdParty = false;
            codeLens.enable = true;
            completion.callSnippet = "Replace";
          };
        };
      };
      nil_ls.enable = true;
      pyright.enable = true;
      rust_analyzer.enable = true;
      taplo.enable = true;
      yamlls.enable = true;
    };
  };
}
