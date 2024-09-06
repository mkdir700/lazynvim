return {
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
