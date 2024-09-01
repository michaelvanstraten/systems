{ pkgs, ... }:
{

  imports = [ ./fish.nix ];

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;

  home.packages = with pkgs; [ eza ];

  home.shellAliases = {
    c = "clear";
    # Replace "ls" with "eza"
    l = "eza";
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    # Git abbreviations
    gc = "git clone";

    nv = "nvim";
    vim = "nvim";
  };
}
