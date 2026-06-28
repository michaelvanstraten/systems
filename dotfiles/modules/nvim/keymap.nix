{ lib, ... }:
let
  inherit (lib.nixvim.utils) mkRaw;
in
{
  keymaps = [
    {
      mode = "i";
      key = "jk";
      action = "<ESC>";
      options.desc = "Escape insert mode";
    }
    {
      mode = "i";
      key = "kj";
      action = "<ESC>";
      options.desc = "Escape insert mode";
    }

    {
      mode = "n";
      key = "q";
      action = "<nop>";
      options.desc = "does nothing to disable recording";
    }

    {
      mode = [
        "i"
        "n"
      ];
      key = "<esc>";
      action = "<cmd>noh<cr><esc>";
      options.desc = "Escape and Clear hlsearch";
    }

    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options = {
        desc = "Go to Left Window";
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options = {
        desc = "Go to Lower Window";
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options = {
        desc = "Go to Upper Window";
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options = {
        desc = "Go to Right Window";
        remap = true;
      };
    }

    {
      mode = "n";
      key = "H";
      action = mkRaw "vim.diagnostic.open_float";
      options.desc = "Show diagnostics in a floating window.";
    }
  ];
}
