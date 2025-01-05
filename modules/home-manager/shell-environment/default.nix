{ pkgs, ... }:
let
  sessionCommand = pkgs.writeShellScriptBin "s" ''
    if [ $# -eq 0 ]; then
        result=$(sesh list | fzf)
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
{
  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd j" ];

  programs.direnv.enable = true;

  programs.sesh.enable = true;
  programs.sesh.enableAlias = false;
  home.packages = [ sessionCommand ];

  imports = [
    ./fish.nix
    ./nushell
    ./starship.nix
  ];
}
