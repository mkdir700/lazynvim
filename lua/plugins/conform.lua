return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  optional = true,
  opts = {
    default_format_opts = {
      undojoin = true,
    },
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" }, -- Conform will run multiple formatters sequentially
      javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
