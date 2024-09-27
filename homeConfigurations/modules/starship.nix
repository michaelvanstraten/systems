{ lib, ... }:
{
  programs.starship = {
    enable = true;

    enableFishIntegration = true;

    settings = {
      # Don't inserts a blank line between shell prompts
      add_newline = false;

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$line_break"
        "$container"
        "$character"
      ];

      git_branch = {
        ignore_branches = [
          "main"
          "master"
        ];
      };
    };
  };
}
