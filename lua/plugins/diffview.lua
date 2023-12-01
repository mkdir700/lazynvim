return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ad", "<CMD>DiffviewOpen<CR>", desc = "Open Diffview" },
  },
  config = function()
    require("diffview").setup({
      keymaps = {
        disable_defaults = true, -- Disable the default key mappings
      },
    })
  end,
}
