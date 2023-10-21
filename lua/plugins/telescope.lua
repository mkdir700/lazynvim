return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    {
      "<leader>ss",
      function()
        require("telescope.builtin").lsp_document_symbols({
          -- FIXME: 无法导入
          -- symbols = require("lazyvim.config").get_kind_filter(),
          symbol_width = 60,
        })
      end,
      desc = "Goto Symbol",
    },
  },
}
