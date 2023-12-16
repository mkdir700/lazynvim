return {
  "Vimjas/vim-python-pep8-indent",
  event = "BufRead",
  ft = { "python" },
  config = function()
    vim.g.python_pep8_indent_multiline_string = 1
  end,
}
