local disabled_plugins = {
  "echasnovski/mini.surround",
  "folke/persistence.nvim",
  "echasnovski/mini.pairs",
}

local results = {}

for _, plugin in ipairs(disabled_plugins) do
  table.insert(results, { plugin, enabled = false })
end

return results
