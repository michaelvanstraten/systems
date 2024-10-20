{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    baseIndex = 1;

    customPaneNavigationAndResize = true;

    keyMode = "vi";

    extraConfig = builtins.readFile ./tmux.conf;

    sensibleOnTop = false;

    plugins = with pkgs.tmuxPlugins; [
      # Enables seamless navigation between tmux panes and vim splits
      vim-tmux-navigator
    ];
  };
}
