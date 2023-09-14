return {
  "rmagatti/goto-preview",
  keys = {
    { "<leader>cp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>" },
  },
  config = function()
    require("goto-preview").setup({})
  end,
}
