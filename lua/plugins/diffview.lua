return {
  "sindrets/diffview.nvim",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ad", "<CMD>DiffviewOpen<CR>", desc = "Open Diffview" },
  },
}
