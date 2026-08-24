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
    require("goto-preview").setup({
      post_open_hook = function(buf, win)
        require("config.goto_preview").attach_definition_preview(buf, win)
      end,
    })
  end,
}
