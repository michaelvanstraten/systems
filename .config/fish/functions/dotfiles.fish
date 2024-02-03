# dotfiles git repo alias 
function dotfiles --wraps git
    switch $argv[1]
        case update
            switch (string lower $argv[2])
                case betterfox
                    set prefix "Library/Application Support/Firefox/Profiles/rf4bf0gc.michael/"
                    set repository Betterfox
                    set ref main
                case "*"
                    echo "Unknown dotfiles subtree."
                    return 1
            end

            cd $HOME && dotfiles subtree pull --prefix $prefix $repository $ref --squash
        case "*"
            git --git-dir=$HOME/.git/ --work-tree=$HOME $argv
    end
end
