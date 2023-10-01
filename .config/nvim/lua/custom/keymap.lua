local M = {}

M.general = {
    i = {
        ["jk"] = { "<ESC>", "escape insert mode", opts = { nowait = true } },
    },

    n = {
        ["q"] = { "<nop>", "does nothing to disable recording" },
        ["<C-j>"] = { ":m+<cr>", "move line down" },
        ["<C-k>"] = { ":m-2<cr>", "move line up" },
        ["<leader>cs"] = { ":nohlsearch<cr>", "clear search" },
    },

    v = {
        ["<C-j>"] = { ":m'>+1<cr>gv", "move seleted lines down" },
        ["<C-k>"] = { ":m'<-2<cr>gv", "move seleted lines up" },
    },
}

M.lspconfig = {
    plugin = true,

    n = {
        ["<leader>rn"] = {
            function()
                require("nvchad.renamer").open()
            end,
            "LSP rename",
        },

        ["M"] = {
            function()
                vim.diagnostic.goto_prev { float = { border = "rounded" } }
            end,
            "Goto prev",
        },

        ["m"] = {
            function()
                vim.diagnostic.goto_next { float = { border = "rounded" } }
            end,
            "Goto next",
        },
    },
}

M.telescope = {
    plugin = true,

    n = {
        ["<leader>ss"] = {
            "<cmd>Telescope spell_suggest<cr>",
            "Spell suggest",
        },

        -- lsp
        ["D"] = {
            "<cmd>Telescope diagnostics<cr>",
            "LSP diagnostics",
        },

        ["gd"] = {
            "<cmd>Telescope lsp_definitions<cr>",
            "LSP definition",
        },

        ["gi"] = {
            "<cmd>Telescope lsp_implementations<cr>",
            "LSP implementation",
        },

        ["gr"] = {
            "<cmd>Telescope lsp_references<cr>",
            "LSP references",
        },
    },
}

M.lazygit = {
    plugin = true,

    n = {
        ["<leader>lg"] = {
            "<cmd>LazyGit<cr>",
            "Open LazyGit",
        },
    },
}

return M
