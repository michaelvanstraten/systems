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
    programs = {
      zoxide = {
        enable = true;
        options = [ "--cmd j" ];
      };

      direnv.enable = true;

      fzf = {
        tmux.enableShellIntegration = true;
        enable = true;
        enableBashIntegration = true;
      };

      sesh = {
        enableAlias = false;
        enable = true;
      };

      bash = {
        historyControl = [
          "ignoredups"
          "ignorespace"
        ];

        historyIgnore = [
          "l"
          "ls"
          "ll"
          "exit"
          "clear"
          "cd"
          "rm*"
        ];

        shellOptions = [
          "histappend"
        ];
      };
    };

    home = {
      packages = [ sessionCommand ];
      shellAliases = {
        c = "clear";
        l = "ls";
        la = "ls -a";
        nv = "nvim";
        lg = "lazygit";
      };
    };
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    home = {
      packages = [ pkgs.xsel ];

      shellAliases = {
        pbcopy = "xsel --clipboard --input";
        pbpaste = "xsel --clipboard --output";
      };
    };
  })
]
