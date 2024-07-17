return {
  "yorickpeterse/nvim-window",
  keys = {
    { "<leader>wJ", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
    { "<M-w>", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
  },
  config = true,
}
