{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    escapeTime = 0;
    terminal = "tmux-256color";
    prefix = if pkgs.stdenv.isDarwin then "C-a" else "M-a";
    customPaneNavigationAndResize = true;
    resizeAmount = 2;

    sensibleOnTop = false;

    plugins = with pkgs.tmuxPlugins; [
      # Enables seamless navigation between tmux panes and vim splits
      vim-tmux-navigator
    ];

    extraConfig =
      # tmux
      ''
        # Session and window behavior
        set -g renumber-windows on
        set-option -g detach-on-destroy on

        # Terminal compatibility
        set -ga terminal-overrides ",*:RGB"
        set -ga terminal-features ",*:usstyle"

        # Clipboard integration
        set -g set-clipboard on

        # Status bar customization
        set -g status-right ""
        set -g status-style "bg=default"

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Window navigation
        bind -r n new-window

        # Window/pane management
        bind e kill-pane
        bind E kill-window
        bind x split-window -h -c "#{pane_current_path}"
        bind y split-window -v -c "#{pane_current_path}"

        # Copy mode
        bind c copy-mode
      '';
  };
}
