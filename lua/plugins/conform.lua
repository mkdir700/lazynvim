return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end, -- Conform will run multiple formatters sequentially
      -- Use a sub-list to run only the first available formatter
      javascript = { { "prettierd", "prettier" } },
    },
  },
}
