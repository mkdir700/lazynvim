return {
  "rmagatti/goto-preview",
  keys = {
    {
      "gp",
      function()
        require("config.goto_preview").goto_preview()
      end,
      desc = "Preview File or Definition",
    },
  },
  config = function()
    require("goto-preview").setup({})
  end,
}
