local disabled_plugins = {
  "echasnovski/mini.surround",
  "echasnovski/mini.pairs",
  "s1n7ax/nvim-window-picker",
  "sychen52/gF-python-traceback",
  "b0o/incline.nvim",
  "ray-x/go.nvim",
  "petertriho/nvim-scrollbar",
}

local results = {}

for _, plugin in ipairs(disabled_plugins) do
  table.insert(results, { plugin, enabled = false })
end

return results
