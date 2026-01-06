local rust = require("config.lang.rust")

if not rust.enabled() then
  return {}
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          check = { command = "check" },
        },
        server = {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "check",
              },
            },
          },
        },
      }
    end,
  },
}
