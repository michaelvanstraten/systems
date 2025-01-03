{ pkgs, ... }:
let
  findMachExecutable = pkgs.writeShellScriptBin "find-mach-executable" ''
    current_dir=$(pwd)

    while [[ "$current_dir" != "/" ]]; do
        if [[ -x "$current_dir/mach" ]]; then
            echo "$current_dir/mach"
            exit 0
        fi
        current_dir=$(dirname "$current_dir")
    done

    exit 1
  '';

  machCommand =
    pkgs.writeShellScriptBin "mach"
      # bash
      ''
        mach_executable=$(find-mach-executable)
        if [[ $? -ne 0 ]]; then
            echo "Error: 'mach' executable not found in any parent directory." >&2
            exit 1
        fi

        exec "$mach_executable" "$@"
      '';

  fishCompletion =
    pkgs.writeTextDir "share/fish/vendor_completions.d/mach.fish"
      # fish
      ''
        function __mach_completion
            set -l mach_executable (find-mach-executable)
            if test $status -ne 0
                return 1
            end

            set -l mach_dir (dirname $mach_executable)
            set -l completion_dir "$mach_dir/.cache/fish/generated_completions"
            set -l completion_script "$completion_dir/mach.fish"

            if not test -f "$completion_script"
                mkdir -p "$completion_dir"

                if not $mach_executable mach-completion fish -f "$completion_script"
                    return 1
                end
            end

            begin
              set -x fish_complete_path "$completion_dir" $fish_complete_path
              complete --do-complete "$(commandline --current-process --cut-at-cursor)"
            end
        end

        complete -c mach -f -a "(__mach_completion)"
      '';

  mach = pkgs.symlinkJoin {
    name = "mach";
    paths = [
      findMachExecutable
      fishCompletion
      machCommand
    ];
  };
in
{
  home.packages = [ mach ];
}
