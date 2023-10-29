return {
    texlab = {
        build = {
            onSave = true,
            executable = "tectonic",
            args = {
                "-X",
                "compile",
                "%f",
                "--synctex",
                "--keep-logs",
                "--keep-intermediates",
            },
            forwardSearchAfter = true,
        },
        forwardSearch = {
            executable = "displayline",
            args = { "-g", "%l", "%p", "%f" },
        },
    },
}
