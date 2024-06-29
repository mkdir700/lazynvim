return {
  "hiphish/rainbow-delimiters.nvim",
  event = "BufRead",
  config = function()
    require("nvim-treesitter.configs").setup({})
  end,
}
