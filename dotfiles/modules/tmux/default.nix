{ pkgs, ... }:
{
  programs.tmux = {
    baseIndex = 1;
    customPaneNavigationAndResize = true;
    extraConfig = builtins.readFile ./tmux.conf;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      # Enables seamless navigation between tmux panes and vim splits
      vim-tmux-navigator
    ];
    sensibleOnTop = false;
  };
}
