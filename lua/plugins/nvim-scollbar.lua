-- 在右侧显示滚动条
return {
  "petertriho/nvim-scrollbar",
  event = "BufRead",
  config = function()
    require("scrollbar").setup()
  end,
}
