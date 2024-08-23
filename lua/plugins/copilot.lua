return {
  {
    "zbirenbaum/copilot.lua",
    enabled = vim.g.code_copilot == "github",
    event = "InsertEnter",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- accept = "<M-f>",
          accept_word = "<C-y>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
    keys = {
      {
        "<leader>uo",
        function()
          require("copilot.suggestion").toggle_auto_trigger()
          vim.notify("Copilot auto trigger: " .. tostring(vim.b.copilot_suggestion_auto_trigger))
        end,
        mode = { "n" },
        desc = "Toggle C(o)pilot auto trigger",
      },
    },
  },
  {
    "luozhiya/fittencode.nvim",
    enabled = vim.g.code_copilot == "fittencode",
    config = function()
      require("fittencode").setup({})
    end,
  },
}
