{ ... }:
{
  programs.fish = {
    enable = true;
    shellInit = ''
      # Disable welcome message
      set fish_greeting
    '';

    shellAbbrs = {
      tn = "tmux new -s (pwd | sed \"s/.*\\///g\")";
      gc = "git clone";
    };
  };
}
