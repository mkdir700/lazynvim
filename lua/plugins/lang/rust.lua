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
      rust.setup_check_scheduler()
      vim.g.rustaceanvim = {
        tools = {
          check = { command = "check" },
        },
        server = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = false,
              check = {
                command = "check",
                extraEnv = {
                  RUSTC_WRAPPER = "",
                },
              },
            },
          },
        },
      }
    end,
  },
}
