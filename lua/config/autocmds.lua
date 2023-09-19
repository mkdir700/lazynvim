-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local Util = require("lazyvim.util")

-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua", "markdown" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Copy to system clipboard on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
      require("osc52").copy_register("+")
    end
  end,
})

-- change workdir to root dir when loading persisted session
local group = vim.api.nvim_create_augroup("PersistedHooks", {})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "PersistedLoadPost",
  group = group,
  callback = function()
    -- change working directory to root of project
    local root_dir = Util.get_root()
    vim.api.nvim_command("cd " .. root_dir)
  end,
})
