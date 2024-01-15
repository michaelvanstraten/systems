function __fish_complete_fish_remove_path
    set -l current_arg (commandline -cp)
    set -l path_elements (string split : $PATH)

    for element in $path_elements
        echo "$element"
    end
end

complete -c fish_remove_path -f -a '(__fish_complete_fish_remove_path)'
