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
    local root_dir = Util.root.get()
    vim.api.nvim_command("cd " .. root_dir)

    -- set the virtualenv from cache if pyproject.toml is present in root dir.
    local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
    if venv ~= "" then
      require("venv-selector").retrieve_from_cache()
    end
  end,
})

-- Auto select virtualenv on Nvim open if pyproject.toml is present
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Auto select virtualenv Nvim open",
  pattern = "*",
  callback = function()
    local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
    if venv ~= "" then
      require("venv-selector").retrieve_from_cache()
    end
  end,
  once = true,
})
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Auto select virtualenv Nvim open",
  pattern = "*",
  callback = function()
    -- if VIRTUAL_ENV is set, then don't do anything
    local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
    if virtual_env then
      return
    end

    local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
    if venv ~= "" then
      require("venv-selector").retrieve_from_cache()
    end
  end,
  once = true,
})
