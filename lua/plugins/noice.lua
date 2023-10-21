return {
  "folke/noice.nvim",
  keys = {
    -- 禁用 noice 的快捷键原因, 详见:
    -- https://github.com/LazyVim/LazyVim/issues/1485
    { "<c-f>", false, mode = { "i", "n", "s" } },
    { "<c-b>", false, mode = { "i", "n", "s" } },
  },
}
