vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "moz.build",
  callback = function()
    vim.bo.filetype = "python"
  end,
})
