{ lib, ... }:
let
  inherit (lib.nixvim.utils) mkRaw;
in
{
  globals = {
    tex_flavor = "latex";
    mapleader = " ";
  };

  opts = {
    # Clipboard
    clipboard = "unnamedplus";

    # Indentation
    shiftwidth = 4;
    tabstop = 4;
    softtabstop = 4;

    # Display
    signcolumn = "yes";
    number = true;
    relativenumber = true;
    pumblend = 10;
    termguicolors = true;
    fillchars = {
      eob = " ";
    };

    colorcolumn = "100";

    # Mouse
    mouse = "a";

    # File handling
    undofile = true;
    swapfile = false;

    # Wrapping and formatting
    wrap = true;
    breakindent = false;

    scrolloff = 3;
    cursorline = true;
    smoothscroll = true;

    # Keyword matching
    iskeyword = mkRaw "vim.opt.iskeyword + '-'";
  };

  filetype = {
    extension = {
      jinja = "jinja";
      jinja2 = "jinja";
      j2 = "jinja";
    };
    pattern = {
      "moz.build" = "python";
    };
  };

  diagnostic.settings = {
    float = {
      border = "rounded";
    };
    severity_sort = true;
  };
}
