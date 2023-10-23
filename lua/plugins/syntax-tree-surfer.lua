return {
  "ziontee113/syntax-tree-surfer",
  event = "BufRead",
  keys = {
    {
      "<C-j>",
      "<cmd>STSSelectNextSiblingNode<cr>",
      desc = "select next sibling node",
      mode = { "x" },
    },
    {
      "<C-k>",
      "<cmd>STSSelectPrevSiblingNode<cr>",
      desc = "select prev sibling node",
      mode = { "x" },
    },
    {
      "<C-p>",
      "<cmd>STSSelectParentNode<cr>",
      desc = "select parent node",
      mode = { "x" },
    },
    {
      "<C-n>",
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
