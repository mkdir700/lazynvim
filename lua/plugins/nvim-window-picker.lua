return {
  "s1n7ax/nvim-window-picker",
  version = "2.*",
  keys = {
    {
      "<leader>wp",
      function()
        local picker = require("window-picker")
        local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(picked_window_id)
      end,
      desc = "Pick Window",
    },
    {
      "<M-w>",
      function()
        local picker = require("window-picker")
        local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(picked_window_id)
      end,
      mode = { "n", "t" },
      desc = "Pick Window",
    },
  },
  config = function()
    require("window-picker").setup({
      hint = "floating-big-letter",
    })
  end,
}
