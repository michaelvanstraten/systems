{ pkgs, lib, ... }:
let
  sessionCommand = pkgs.writeShellScriptBin "s" ''
    if [ $# -eq 0 ]; then
        result=$(sesh list --icons | fzf --ansi)
    elif [[ $# -eq 1 && $1 == '-' ]]; then
        sesh last
        exit 0
    elif [[ $# -eq 1 && -d $1 ]]; then
        result=$1
    else
        result=$(zoxide query --exclude "$(pwd)" -- "$@")
    fi

    if [ -n "$result" ]; then
        sesh connect "$result"
    else
        echo "No valid session or directory found."
        exit 1
    fi
  '';
in
lib.mkMerge [
  {
    programs.zoxide.enable = true;
    programs.zoxide.options = [ "--cmd j" ];

    programs.direnv.enable = true;

    home.packages = [
      pkgs.fzf
      sessionCommand
    ];
    programs.fzf.tmux.enableShellIntegration = true;
    programs.sesh.enableAlias = false;
    programs.sesh.enable = true;

    home.shellAliases = {
      c = "clear";
      l = "ls";
      la = "ls -a";
      nv = "nvim";
      lg = "lazygit";
    };
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ pkgs.xsel ];

    home.shellAliases = {
      pbcopy = "xsel --clipboard --input";
      pbpaste = "xsel --clipboard --output";
    };
  })
]
