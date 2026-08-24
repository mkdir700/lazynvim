return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
  {
    "sainnhe/everforest",
    init = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_dim_inactive_windows = 1
    end,
  },
}
