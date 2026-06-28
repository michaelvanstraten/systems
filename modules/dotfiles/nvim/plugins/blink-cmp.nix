{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      keymap.preset = "super-tab";

      completion = {
        menu.border = "rounded";
        documentation.window.border = "rounded";
      };

      signature.window.border = "rounded";

      appearance = {
        use_nvim_cmp_as_default = false;
        nerd_font_variant = "normal";
      };

      sources.default = [
        "lsp"
        "path"
        "snippets"
        "buffer"
      ];
    };
  };
}
