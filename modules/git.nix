{ ... }: {
  programs.git = {
    enable = true;

    userName = "Michael van Straten";
    userEmail = "michael@vanstraten.de";
    # signingkey = "B7AA2A517BE93CB27B3B980AA81434236CF08641";

    ignores = [ ".DS_Store" ".vscode/" ".venv/" ];

    extraConfig = {
      init.defaultBranch = "master";
      core = {
        editor = "nvim";
        ignorecase = false;
        fsmonitor = true;
        untrackedcache = true;
      };
      pull.rebase = true;
      push.default = "current";
      cinnabar.version-check = 1707138726;
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
      # commit.gpgsign = true;
      rerere.enabled = true;
      branch.sort = "-committerdate";
    };
  };
}
