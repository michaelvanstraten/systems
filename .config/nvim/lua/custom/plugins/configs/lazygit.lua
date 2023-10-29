local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new {
    cmd = string.format("lazygit --git-dir=%s --work-tree=%s", vim.env.GIT_DIR or "", vim.env.GIT_WORK_TREE or ""),
    hidden = true,
    direction = "float",
    float_opts = {
        border = "single",
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd "startinsert!"
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function()
        vim.cmd "startinsert!"
    end,
}

M.toggle = function()
    lazygit:toggle()
end

return M
