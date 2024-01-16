return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  optional = true,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      python = { "isort", "black" }, -- Conform will run multiple formatters sequentially
      -- Use a sub-list to run only the first available formatter
      javascript = { { "prettierd", "prettier" } },
    },
  },
}
