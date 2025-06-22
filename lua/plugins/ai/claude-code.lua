return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  keys = { { "<leader>al", ":ClaudeCode<cr>", desc = "Claude Code" } },
  config = function()
    require("claude-code").setup({
      window = {
        position = "rightbelow vsplit",
      }
    })
  end
}
