-- lua/plugins/lang/csharp.lua
local dotnet = require("config.lang.dotnet")

if not dotnet.enabled() then
  return {}
end

return {
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
  },
  {
    "Issafalcon/neotest-dotnet",
  },
}
