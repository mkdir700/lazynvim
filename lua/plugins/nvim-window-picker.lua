return {
  "s1n7ax/nvim-window-picker",
  version = "2.*",
  event = "VeryLazy",
  keys = {
    {
      "<leader>wp",
      function()
        require("window-picker").pick_window()
      end,
      desc = "Pick Window",
    },
  },
  config = function()
    require("window-picker").setup({
      hint = "floating-big-letter",
    })
  end,
}
