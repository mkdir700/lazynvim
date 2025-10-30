return {
  "https://github.com/swaits/zellij-nav.nvim",
  enabled = function()
    -- Zellij sets one or more of these env vars when running inside a session
    return vim.env.ZELLIJ ~= nil
      or vim.env.ZELLIJ_SESSION ~= nil
      or vim.env.ZELLIJ_SESSION_NAME ~= nil
      or vim.env.ZELLIJ_EXECUTION_CONTEXT ~= nil
  end,
  config = function()
    require("zellij-nav").setup()

    local map = vim.keymap.set
    map("n", "<leader>zh", "<cmd>ZellijNavigateLeftTab<cr>", { desc = "navigate left or tab" })
    map("n", "<leader>zj", "<cmd>ZellijNavigateDown<cr>", { desc = "navigate down" })
    map("n", "<leader>zk", "<cmd>ZellijNavigateUp<cr>", { desc = "navigate up" })
    map("n", "<leader>zl", "<cmd>ZellijNavigateRightTab<cr>", { desc = "navigate right or tab" })
  end,
}
