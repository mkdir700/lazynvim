-- 自动关闭 buffer
-- The main feature of this plugin, however,
-- is the automatic closing of buffers.
-- If the number of buffers reaches a threshold (default is 10), the oldest unedited buffer will be closed once you open a new one.
return {
  "axkirillov/hbac.nvim",
  config = true,
}
