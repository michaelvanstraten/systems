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
        latexindent = fmt pkgs.texlivePackages.latexindent;
        meson = fmt pkgs.meson;
        nixfmt = fmt pkgs.nixfmt;
        packer_fmt = fmt pkgs.packer;
        prettier = fmt pkgs.prettier;
        ruff_format = fmt pkgs.ruff;
        rustfmt = fmt pkgs.rustfmt;
        shfmt = fmt pkgs.shfmt;
        stylua = fmt pkgs.stylua;
        swift_format = fmt pkgs.swift-format;
        taplo = fmt pkgs.taplo;
        terraform_fmt = fmt pkgs.opentofu;
        typstyle = fmt pkgs.typstyle;
      };

      formatters_by_ft = {
        cpp = [ "clang-format" ];
        fish = [ "fish_indent" ];
        hcl = [ "packer_fmt" ];
        javascript = [ "prettier" ];
        json = [ "prettier" ];
        lua = [ "stylua" ];
        markdown = [ "prettier" ];
        meson = [ "meson" ];
        nix = [ "nixfmt" ];
        python = [ "ruff_format" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        svg = [ "prettier" ];
        swift = [ "swift_format" ];
        terraform = [ "terraform_fmt" ];
        tex = [ "latexindent" ];
        toml = [ "taplo" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        typst = [ "typstyle" ];
        yaml = [ "prettier" ];
      };
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "packer"
    ];
}
