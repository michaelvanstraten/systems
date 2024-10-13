{ ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      c = "clear";
      gc = "git clone";
      l = "ls";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
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
