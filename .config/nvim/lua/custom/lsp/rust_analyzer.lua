return {
    ["rust-analyzer"] = {
        check = {
            features = "all",
            command = "clippy",
        },
        import = {
            granularity = {
                enforce = true,
                group = "module",
            },
        },
    },
}
