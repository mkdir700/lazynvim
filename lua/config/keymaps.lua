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

map("x", "L", "$")
map("x", "H", "$")
map("x", "p", "P")

-- terminal: single press exits insert, double press hides buffer
do
  local term_escape = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
  local threshold = 300 -- ms window for double-tap detection

  local function terminal_ctrl_q()
    if vim.bo.buftype ~= "terminal" then
      return
    end

    local now = vim.loop.hrtime() / 1e6
    local state = vim.b._ctrl_q_state or { last = 0, from_insert = false }
    local elapsed = now - (state.last or 0)
    local double = state.last ~= 0 and elapsed <= threshold
    local mode = vim.api.nvim_get_mode().mode

    if double and state.from_insert then
      if mode == "t" then
        vim.api.nvim_feedkeys(term_escape, "n", true)
      end
      vim.b._terminal_last_mode = "n"
      vim.b._ctrl_q_state = { last = 0, from_insert = false }
      local buf = vim.api.nvim_get_current_buf()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.cmd("hide")
        end
      end)
      return
    end

    if mode == "t" then
      vim.api.nvim_feedkeys(term_escape, "n", true)
      vim.b._terminal_last_mode = "n"
      vim.b._ctrl_q_state = { last = now, from_insert = true }
    else
      vim.cmd("startinsert")
      vim.b._terminal_last_mode = "t"
      vim.b._ctrl_q_state = { last = now, from_insert = false }
    end
  end

  vim.keymap.set({ "t", "n" }, "<C-q>", terminal_ctrl_q, { desc = "Terminal ctrl-q actions" })
end

-- plugins: lsp
map("n", "<leader>ar", ":LspRestart<cr>", { desc = "Restart LSP" })

-- plugins: dial.nvim
-- 判断 dial.nvim 插件是否安装
if pcall(require, "dial.augend") then
  map("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
  map("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
  map("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
  map("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
  -- vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
  -- vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
end

-- plugins: nvim-treesitter
if pcall(require, "nvim-treesitter.textobjects.repeatable_move") then
  local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
  -- vim way: ; goes to the direction you were moving.
  -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
  -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
end

vim.keymap.set("n", "<leader>we", ":Neotree focus<cr>", { desc = "Focus Neotree" })
