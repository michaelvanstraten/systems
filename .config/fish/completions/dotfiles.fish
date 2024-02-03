complete --command dotfiles --condition "__fish_seen_subcommand_from update" --no-files --arguments "Betterfox"
complete --command dotfiles --condition "not __fish_seen_subcommand_from update" --arguments "update" --description "Update the specified subtree"
