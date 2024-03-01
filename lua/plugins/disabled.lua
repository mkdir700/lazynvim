local disabled_plugins = {
  "echasnovski/mini.surround",
  "echasnovski/mini.pairs",
  "s1n7ax/nvim-window-picker"
}

local results = {}

for _, plugin in ipairs(disabled_plugins) do
  table.insert(results, { plugin, enabled = false })
end

return results
