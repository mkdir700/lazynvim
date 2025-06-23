return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {
      name = "venv",
      auto_refresh = false,
    },
    event = "VeryLazy",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
  {
    "roobert/f-string-toggle.nvim",
    event = "BufRead",
    ft = { "python" },
    config = function()
      require("f-string-toggle").setup({
        key_binding = "<leader>cz",
        key_binding_desc = "Toggle f-string",
      })
    end,
  },
  {
    "Vimjas/vim-python-pep8-indent",
    event = "BufRead",
    ft = { "python" },
    config = function()
      vim.g.python_pep8_indent_multiline_string = 1
    end,
  },
}
