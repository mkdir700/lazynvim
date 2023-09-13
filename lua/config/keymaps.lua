-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("i", "jk", "<Esc>")

-- emac style
map("i", "<C-f>", "<Right>")
map("i", "<C-b>", "<Left>")
map("i", "<C-a>", "<Esc>I")
map("i", "<C-e>", "<Esc>A")

-- 退出编辑器
map("n", "Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- 缩进
map("n", ">", ">>")
map("n", "<", "<<")

map("x", "L", "$")
map("x", "H", "$")
map("v", "p", "P")

-- plugins: dial.nvim
-- 判断 dial.nvim 插件是否安装
-- vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
-- vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
if pcall(require, "dial.augend") then
  map("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
  map("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
  map("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
  map("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
end

-- plugins: nvim-treesitter
if pcall(require, "nvim-treesitter.textobjects.repeatable_move") then
  local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
  -- vim way: ; goes to the direction you were moving.
  -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
  -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
end
