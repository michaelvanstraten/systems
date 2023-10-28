return {
    texlab = {
        -- diagnosticsDelay = 100,
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
        -- auxDirectory = "build/default/",
        -- build = {
        --     onSave = true,
        --     filename = "default.pdf",
        --     executable = "tectonic",
        --
        --     args = {
        --         "-X",
        --         "build",
        --         "--keep-logs",
        --         "--keep-intermediates",
        --     },
        --     forwardSearchAfter = true,
        -- },
        forwardSearch = {
            executable = "/opt/homebrew/bin/zathura",
            args = { "--synctex-forward", "%l:1:%f", "%p" },
        },
    },
}
