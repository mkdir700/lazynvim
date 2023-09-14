-- 使得非正在编辑的部分变暗
return {
  "folke/zen-mode.nvim",
  event = "InsertEnter",
  dependencies = {
    "folke/twilight.nvim",
  },
  keys = {
    {
      "<leader>uz",
      "<cmd>Twilight<cr>",
      desc = "Toggle Zen Mode",
    },
  },
}
