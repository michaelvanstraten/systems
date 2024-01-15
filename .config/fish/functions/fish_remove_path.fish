function fish_remove_path --description "Remove the first occurrence of a directory from PATH and fish_user_paths"
    set -q argv[1] || return 1  # Ensure an argument is provided

    for var in PATH fish_user_paths
        if set -q index (contains -i $argv[1] $$var)
            set -e $var[$index]
            echo "Updated $var"
            set -l path_updated 1
        end
    end

    if not set -q path_updated
        echo "No changes were made to PATH or fish_user_paths"
    end
end
