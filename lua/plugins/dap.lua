return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      -- LazyVim's TypeScript DAP config keeps a `chrome` alias for pwa-chrome,
      -- but mason-nvim-dap maps that alias to the retired chrome-debug-adapter
      -- package. Exclude only the legacy alias; js-debug-adapter still provides
      -- the pwa-chrome adapter used for JavaScript and TypeScript debugging.
      automatic_installation = {
        exclude = { "chrome" },
      },
    },
  },
}
