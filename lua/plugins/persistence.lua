return {
  "mkdir700/persistence.nvim",
  event = "BufReadPre",
  opts = {
    options = vim.opt.sessionoptions:get(),
    post_load = function()
      -- Select Python Virtual Environment
      local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
      if type(virtual_env) == "string" then
        return
      end
      local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
      if venv ~= "" then
        require("venv-selector").retrieve_from_cache()
      end
    end,
  },
  -- stylua: ignore
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
