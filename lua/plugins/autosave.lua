-- return {
--   "okuuva/auto-save.nvim",
--   cmd = "ASToggle", -- optional for lazy loading on command
--   event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
--   opts = {
--     trigger_events = {
--       -- defer_save = { "InsertLeave" },
--       -- cancel_defered_save = { "TextChanged" },
--     },
--     debounce_delay = 200,
--   },
--   keys = {
--     {
--       "<leader>as",
--       ":ASToggle<CR>",
--       desc = "Toggle autosave",
--     },
--   },
-- }
return {
  "Pocco81/auto-save.nvim",
  lazy = false,
  opts = {
    debounce_delay = 500,
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")

      -- First check the default conditions
      if not (fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {})) then
        return false
      end

      -- Exclude claudecode diff buffers by buffer name patterns
      -- for claudecode diff buffers, the buffer name is set to
      -- "(proposed)" or "(NEW FILE - proposed)" or "(New)"
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:match("%(proposed%)") or bufname:match("%(NEW FILE %- proposed%)") or bufname:match("%(New%)") then
        return false
      end

      -- Exclude by buffer variables (claudecode sets these)
      if
        vim.b[buf].claudecode_diff_tab_name
        or vim.b[buf].claudecode_diff_new_win
        or vim.b[buf].claudecode_diff_target_win
      then
        return false
      end

      -- Exclude by buffer type (claudecode diff buffers use "acwrite")
      local buftype = fn.getbufvar(buf, "&buftype")
      if buftype == "acwrite" then
        return false
      end

      return true -- Safe to auto-save
    end,
  },
  keys = {
    { "<leader>uv", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
  },
}
