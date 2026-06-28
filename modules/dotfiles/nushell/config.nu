# Disable the startup banner
$env.config.show_banner = false

# Always move files to the trash instead of permanently deleting them
$env.config.rm.always_trash = true

# Highlight resolved external commands
$env.config.highlight_resolved_externals = true

# Customize color configuration
$env.config.color_config = {
    shape_external: red
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
}

# Customize the completion menu
$env.config.menus = [
    {
        name: completion_menu
        only_buffer_difference: false
        marker: ""
        type: {
            layout: columnar
            columns: 4
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
    }
]

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | from tsv --flexible --noheaders --no-infer
    | rename value description
}

let external_completer = {|spans|
    # if the current command is an alias, get it's expansion
    let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

    # overwrite
    let spans = (if $expanded_alias != null  {
        # put the first word of the expanded alias first in the span
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else { $spans })

    match $spans.0 {
        _ => $fish_completer
    } | do $in $spans
}

$env.config.completions = {
    external: {
        enable: true
        completer: $external_completer
    }
}
