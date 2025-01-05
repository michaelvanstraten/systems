{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      gc = "git clone";
    };

    interactiveShellInit = # fish
      ''
        set fish_greeting # Disable greeting
      '';
  };
}
