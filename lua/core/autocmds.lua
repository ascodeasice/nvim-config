-- allow running cells when entering jupyter notebook
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.ipynb",
  callback = function()
    vim.cmd("QuartoActivate")
    vim.cmd("MoltenInit python3") -- use the system python kernel by default
  end,
})
