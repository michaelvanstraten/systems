{ pkgs, ... }:
{
  home.file.".config/nvim".source = ./.;

  home.packages = [ pkgs.neovim ];
}
