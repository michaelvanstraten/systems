{ ... }:
{
  programs.git = {
    enable = true;

    ignores = [
      ".DS_Store"
      ".vscode/"
      ".venv/"
    ];

    extraConfig = {
      init.defaultBranch = "master";
      core = {
        ignorecase = false;
      };
      pull.rebase = true;
      push.default = "current";
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
      rerere = {
        enabled = true;
      };
      branch = {
        sort = "-committerdate";
      };
    };
  };

  programs.git.lfs.enable = true;
}
