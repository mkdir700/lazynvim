return {
  "georgeguimaraes/review.nvim",
  version = "v*",
  dependencies = {
    "esmuellert/codediff.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = { "Review" },
  keys = {
    { "<leader>gr", "<cmd>Review<cr>", desc = "Review changes" },
    { "<leader>gR", "<cmd>Review commits<cr>", desc = "Review commits" },
  },
  opts = {},
}
