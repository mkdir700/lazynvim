return {
  {
    "zbirenbaum/copilot.lua",
    enabled = vim.g.code_copilot == "github",
    event = "InsertEnter",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = function(_, opts)
      opts = opts or {}
      opts.suggestion = vim.tbl_deep_extend("force", {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- accept = "<M-f>",
          accept_word = "<C-y>",
        },
      }, opts.suggestion or {})
      opts.panel = vim.tbl_deep_extend("force", { enabled = false }, opts.panel or {})
      opts.filetypes = vim.tbl_deep_extend("force", {
        markdown = true,
        help = true,
      }, opts.filetypes or {})
      return opts
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
      LazyVim.cmp.actions.ai_accept = function()
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and suggestion.is_visible() then
          LazyVim.create_undo()
          suggestion.accept()
          return true
        end
      end
    end,
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
    "supermaven-inc/supermaven-nvim",
    enabled = vim.g.code_copilot == "supermaven",
    config = function()
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          LazyVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end

      require("supermaven-nvim").setup({
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
      })
    end,
  },
}
