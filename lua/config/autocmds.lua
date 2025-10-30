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

-- Copy to system clipboard on yank if SSH_TTY is set
if os.getenv("SSH_TTY") or os.getenv("WSL_DISTRO_NAME") then
  vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
      require("osc52").copy_register("+")
    end,
  })
end

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
      local cache = require("venv-selector.cached_venv")
      cache.retrieve()
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
      local cache = require("venv-selector.cached_venv")
      cache.retrieve()
    end
  end,
  once = true,
})
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Auto select virtualenv BufReadPre",
  pattern = "*",
  callback = function()
    -- if VIRTUAL_ENV is set, then don't do anything
    local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
    -- vim.notify(type(virtual_env), "debug")
    if type(virtual_env) == "string" then
      vim.notify("VIRTUAL_ENV is set, not doing anything", "debug")
      return
    end

    local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
    if venv ~= "" then
      local cache = require("venv-selector.cached_venv")
      cache.retrieve()
    end
  end,
  once = true,
})

local function auto_activate_python_venv()
  -- NOTE: 在 venv-selector 中被设置 VIRTUAL_ENV 环境变量
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  local is_windows = vim.loop.os_uname().version:match("Windows")
  -- 是否为首次打开终端
  if virtual_env ~= vim.NIL then
    if is_windows then
      vim.api.nvim_chan_send(vim.b.terminal_job_id, string.format("%s/Scripts/activate", virtual_env) .. "\n")
      vim.api.nvim_chan_send(vim.b.terminal_job_id, "cls\n")
    else
      -- 打开终端后，自动执行激活虚拟环境命令
      -- 如果当前终端是 fish
      if vim.o.shell:find("fish") then
        vim.api.nvim_chan_send(vim.b.terminal_job_id, string.format("source %s/bin/activate.fish", virtual_env) .. "\n")
      else
        -- 如果当前终端是 bash
        vim.api.nvim_chan_send(vim.b.terminal_job_id, string.format("source %s/bin/activate", virtual_env) .. "\n")
      end
      vim.api.nvim_chan_send(vim.b.terminal_job_id, "clear\n")
    end
  end
end

-- 在打开终端时自动执行命令
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local bufname = vim.fn.bufname()
    local shell_type = vim.fn.fnamemodify(vim.env.SHELL or "", ":t")
    -- vim.notify(bufname, "debug")
    -- vim.notify(shell_type, "debug")
    if bufname:match("term://.*//.*/" .. shell_type .. "$") then
      auto_activate_python_venv()
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  desc = 'Zellij return to normal mode on exit Neovim',
  pattern = "*",
  command = "silent !zellij action switch-mode normal",
})

vim.api.nvim_create_autocmd("BufReadPre", {
  desc = 'Zellij lock tab on enter Neovim',
  pattern = "*",
  command = "silent !zellij action switch-mode locked",
})
