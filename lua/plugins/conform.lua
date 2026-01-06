return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  optional = true,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" }, -- Conform will run multiple formatters sequentially
      -- Use a sub-list to run only the first available formatter
      javascript = { { "prettierd", "prettier" } },
    },
  },
}
