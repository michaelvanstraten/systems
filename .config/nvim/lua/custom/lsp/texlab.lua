return {
    texlab = {
        build = {
            executable = "tectonic",
            args = {
                "-X",
                "compile",
                "%f",
                "--synctex",
                "--keep-logs",
                "--keep-intermediates",
                "-Z",
                "continue-on-errors",
            },
            onSave = true,
            forwardSearchAfter = true,
        },
        forwardSearch = {
            executable = "displayline",
            args = { "-g", "%l", "%p", "%f" },
        },
    },
}
