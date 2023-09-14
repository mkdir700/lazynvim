return {
  "rmagatti/goto-preview",
  keys = {
    {
      "gp",
      "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
      desc = "Goto Preview Definition",
    },
  },
  config = function()
    require("goto-preview").setup({})
  end,
}
