{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      gc = "git clone";
      tn = "tmux new -s (pwd | sed \"s/.*\///g\")";
    };

    shellAliases = {
      # Prevent my self from my self (i recently `rm -rf` my home directory)
      rm = "rm -i";
    };

    shellInit = ''
      # Disable welcome message
      set fish_greeting
    '';
  };
}
