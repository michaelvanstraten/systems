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
