return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {
    execution_message = {
      enabled = false,
    },
    trigger_events = {
      defer_save = { "InsertLeave" },
      -- cancel_defered_save = { "TextChanged" },
    },
    debounce_delay = 200,
  },
  keys = {
    {
      "<leader>as",
      ":ASToggle<CR>",
      desc = "Toggle autosave",
    },
  },
}
