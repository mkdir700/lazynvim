return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
    picker = {
      win = {
        input = { keys = { ["<C-w>"] = false } },
        list = { keys = { ["<C-w>"] = false } },
      },
    },
  },
  keys = {
    { "<leader>sW", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    {
      "<leader>sw",
      LazyVim.pick("grep_word", { root = false }),
      desc = "Visual selection or word (cwd)",
      mode = { "n", "x" },
    },
    { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },  -- 谁在内部调用了我
    { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },  -- 我在内部调用了谁
  },
}
