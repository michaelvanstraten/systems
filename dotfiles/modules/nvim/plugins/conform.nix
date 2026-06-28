{ lib, pkgs, ... }:
let
  inherit (lib.nixvim.utils) mkRaw;
  fmt = pkg: { command = lib.getExe pkg; };
  fmt' = pkg: bin: { command = lib.getExe' pkg bin; };
in
{
  keymaps = [
    {
      key = "<leader>f";
      action = mkRaw ''function() require("conform").format() end'';
      mode = [
        "n"
        "v"
      ];
    }
  ];

  plugins.conform-nvim = {
    enable = true;

    settings = {
      default_format_opts = {
        timeout_ms = 3000;
        async = false;
        quiet = false;
      };

      formatters = {
        clang-format = fmt pkgs.clang-tools;
        fish_indent = fmt' pkgs.fish "fish_indent";
        prettier = fmt pkgs.prettier;
        stylua = fmt pkgs.stylua;
        nixfmt = fmt pkgs.nixfmt;
        ruff_format = fmt pkgs.ruff;
        rustfmt = fmt pkgs.rustfmt;
        shfmt = fmt pkgs.shfmt;
        swift_format = fmt pkgs.swift-format;
        latexindent = fmt pkgs.texlivePackages.latexindent;
        taplo = fmt pkgs.taplo;
        typstyle = fmt pkgs.typstyle;
        meson = fmt pkgs.meson;
      };

      formatters_by_ft = {
        cpp = [ "clang-format" ];
        fish = [ "fish_indent" ];
        javascript = [ "prettier" ];
        json = [ "prettier" ];
        lua = [ "stylua" ];
        markdown = [ "prettier" ];
        nix = [ "nixfmt" ];
        python = [ "ruff_format" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        swift = [ "swift_format" ];
        tex = [ "latexindent" ];
        toml = [ "taplo" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        typst = [ "typstyle" ];
        yaml = [ "prettier" ];
        meson = [ "meson" ];
      };
    };
  };
}
