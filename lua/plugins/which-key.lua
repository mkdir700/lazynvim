return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>a", group = "application" },
      {
        "<leader>b",
        group = "buffer",
        expand = require("util.buffer_switcher").expand,
      },
    },
  },
}
