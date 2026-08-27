local rust = require("config.lang.rust")

if not rust.enabled() then
  return {}
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "rust-analyzer") then
        table.insert(opts.ensure_installed, "rust-analyzer")
      end
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    init = function()
      rust.setup_check_scheduler()
      require("util.rust_module").setup()
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
