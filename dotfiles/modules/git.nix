{ lib, ... }:
{
  programs.git = {
    ignores = [
      ".DS_Store"
      ".vscode/"
      ".venv/"
      ".cache/"
    ];

    lfs.enable = true;

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
      branch.sort = "-committerdate";
    };

    userName = "Michael van Straten";
    userEmail = lib.mkDefault "michael@vanstraten.de";
  };
}
