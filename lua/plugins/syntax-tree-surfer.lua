return {
  "ziontee113/syntax-tree-surfer",
  event = "BufRead",
  keys = {
    {
      "J",
      "<cmd>STSSelectNextSiblingNode<cr>",
      desc = "select next sibling node",
      mode = { "x" },
    },
    {
      "<cmd>STSSelectPrevSiblingNode<cr>",
      "K",
      desc = "select prev sibling node",
      mode = { "x" },
    },
    {
      "P",
      "<cmd>STSSelectParentNode<cr>",
      desc = "select parent node",
      mode = { "x" },
    },
    {
      "N",
      "<cmd>STSSelectChildNode<cr>",
      desc = "select child node",
      mode = { "x" },
    },
    {
      "<A-J>",
      "<cmd>STSSwapNextVisual<cr>",
      desc = "swap next visual",
      mode = { "x" },
    },
    {
      "<A-K>",
      "<cmd>STSSwapPrevVisual<cr>",
      desc = "swap prev visual",
      mode = { "x" },
    },
  },
  config = function()
    require("syntax-tree-surfer").setup({})
  end,
}
