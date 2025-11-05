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

    settings = {
      init.defaultBranch = "main";
      core.ignorecase = false;
      pull.rebase = true;
      push.default = "current";
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
      branch.sort = "-committerdate";
      user.name = "Michael van Straten";
      user.email = lib.mkDefault "michael@vanstraten.de";
    };
  };
}
