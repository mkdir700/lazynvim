return {
  "lewis6991/gitsigns.nvim",
  keys = {
    { "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame<cr>", mode = { "n" }, desc = "Toggle Git Blame" },
    { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", mode = { "n" }, desc = "Preview Hunk" },
    { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", mode = { "n" }, desc = "Next Hunk" },
    { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", mode = { "n" }, desc = "Prev Hunk" },
    { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", mode = { "n" }, desc = "Git Diff" },
  },
  opts = {
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 300,
      ignore_whitespace = false,
    },
  },
}
