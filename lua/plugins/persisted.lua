return {
  "olimorris/persisted.nvim",
  event = "VimEnter",
  keys = {
    { "<leader>qv", "<CMD>Telescope persisted<CR>", desc = "View Sessions" },
    { "<leader>ql", "<CMD>SessionLoad<CR>", desc = "Load Session" },
    { "<leader>qL", "<CMD>SessionLoadLast<CR>", desc = "Load Last Session" },
    { "<leader>qs", "<CMD>SessionStart<CR>", desc = "Start Record Current Session" },
    { "<leader>qt", "<CMD>SessionStop<CR>", desc = "Stop Record Current Session" },
  },
  config = function()
    require("persisted").setup({
      telescope = {
        reset_prompt_after_deletion = false,
        after_source = function(param)
          vim.api.nvim_command("%bd")
          local path = param.dir_path
          if string.find(path, "/") ~= 1 then
            vim.api.nvim_command("cd " .. vim.fn.expand("~") .. "/" .. path)
            vim.api.nvim_command("tcd " .. vim.fn.expand("~") .. "/" .. path)
          else
            vim.api.nvim_command("cd " .. path)
            vim.api.nvim_command("tcd " .. path)
          end
        end,
      },
    })
    require("telescope").load_extension("persisted") -- To load the telescope extension
  end,
}
