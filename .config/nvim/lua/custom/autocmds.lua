local function is_tracked_by_git(path, git_dir, work_tree)
    local cmd = { "git", "--git-dir", git_dir, "--work-tree", work_tree, "ls-files", path }
    local out = vim.fn.system(cmd)

    return vim.v.shell_error == 0 and out and #out ~= 0 and not out:match "fatal"
end

local GIT_DIR = vim.fn.expand "$HOME/.dotfiles/"
local WORK_TREE = vim.fn.expand "$HOME"

local function set_git_env()
    vim.env.GIT_WORK_TREE = WORK_TREE
    vim.env.GIT_DIR = GIT_DIR
end

local function unset_git_env()
    vim.env.GIT_WORK_TREE = nil
    vim.env.GIT_DIR = nil
end

vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function(_)
        if is_tracked_by_git(vim.fn.getcwd(), GIT_DIR, WORK_TREE) then
            set_git_env()
        end
    end,
})

vim.api.nvim_create_autocmd({ "DirChanged" }, {
    callback = function(data)
        if is_tracked_by_git(data.file, GIT_DIR, WORK_TREE) then
            set_git_env()
        else
            unset_git_env()
        end
    end,
})

--- Open nvim-tree for directories on startup
local function open_nvim_tree(data)
    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1
    -- buffer was specified
    local empty = data.file == ""

    if not directory and not empty then
        return
    end

    -- change to the directory
    if not empty then
        vim.cmd.cd(data.file)
    end

    -- open the tree
    require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
