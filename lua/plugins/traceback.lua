return {
  -- traceback jump plugin
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins/traceback-jump",
    dependencies = {
      "willothy/flatten.nvim",
    },
    config = function()
      return require("plugins.traceback-jump")
    end,
  },
}
