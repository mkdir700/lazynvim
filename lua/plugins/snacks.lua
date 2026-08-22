return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
    input = {
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
      },
    },
    terminal = {
      win = {
        keys = {
          hide_slash = false,
          hide_underscore = false,
        },
      },
    },
    picker = {
      win = {
        input = { keys = { ["<C-w>"] = false } },
        list = { keys = { ["<C-w>"] = false } },
      },
    },
  },
  keys = {
    {
      "<leader>sf",
      LazyVim.pick("files", {
        root = false,
        pattern = function(picker)
          return picker:word()
        end,
      }),
      desc = "Find Files (cwd)",
      mode = "x",
    },
    {
      "<leader>sF",
      LazyVim.pick("files", {
        pattern = function(picker)
          return picker:word()
        end,
      }),
      desc = "Find Files (Root Dir)",
      mode = "x",
    },
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
