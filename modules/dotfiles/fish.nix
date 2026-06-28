{
  programs.fish = {
    shellAbbrs = {
      gc = "git clone";
    };

    interactiveShellInit = # fish
      ''
        set fish_greeting # Disable greeting
      '';
  };
}
