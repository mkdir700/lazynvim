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
if os.getenv("SSH_TTY") then
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
    vim.notify(type(virtual_env), "debug")
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

-- -- Toggle f-string on insert leave and text change
-- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--   desc = "f-string toggle",
--   pattern = "*.py",
--   callback = function()
--     local ts_utils = require("nvim-treesitter.ts_utils")
--     local winnr = vim.api.nvim_get_current_win()
--     local cursor = vim.api.nvim_win_get_cursor(winnr)
--     local node = ts_utils.get_node_at_cursor()
--
--     while (node ~= nil) and (node:type() ~= "string") do
--       node = node:parent()
--     end
--
--     if node == nil then
--       return
--     end
--
--     local find_brackets = function(str)
--       return str:find("{") and str:find("}")
--     end
--
--     local str_content = vim.api.nvim_get_current_line()
--     local has_brackets = find_brackets(str_content)
--
--     local srow, scol, ecol, erow = ts_utils.get_vim_range({ node:range() })
--     vim.fn.setcursorcharpos({ srow, scol })
--     local char = vim.api.nvim_get_current_line():sub(scol, scol)
--     local is_fstring = (char == "f")
--
--     if has_brackets and not is_fstring then
--       vim.cmd("normal if")
--
--       -- if cursor is in the same line as text change
--       if srow == cursor[1] then
--         -- positive offset to cursor
--         cursor[2] = cursor[2] + 1
--       end
--     else
--       if not has_brackets and is_fstring then
--         vim.cmd("normal x")
--         -- if cursor is in the same line as text change
--         if srow == cursor[1] then
--           -- negative offset to cursor
--           cursor[2] = cursor[2] - 1
--         end
--       end
--     end
--
--     vim.api.nvim_win_set_cursor(winnr, cursor)
--   end,
-- })
