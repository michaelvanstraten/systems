local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new {
    cmd = string.format("lazygit --git-dir=%s --work-tree=%s", vim.env.GIT_DIR or "", vim.env.GIT_WORK_TREE or ""),
    hidden = true,
    direction = "float",
    float_opts = {
        border = "single",
    },
}

M.toggle = function()
    lazygit:toggle()
end

return M
