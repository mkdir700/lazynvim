return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        split = {
          width = 60,
        },
        keys = {
          select_session = {
            "<c-s>",
            function()
              vim.cmd.stopinsert()
              vim.schedule(function()
                require("util.sidekick_sessions").select()
              end)
            end,
            mode = { "n", "t" },
            desc = "Select CLI Session",
          },
          stopinsert_ctrl_u = {
            "<c-u>",
            "stopinsert",
            mode = "t",
            desc = "Enter normal mode",
          },
        },
      },
      mux = {
        backend = "tmux",
        enabled = true,
      },
      tools = {
        codex = {
          cmd = { "codex", "--dangerously-bypass-approvals-and-sandbox" },
        },
      },
      prompts = {
        gen_commit_message = require("plugins.ai.prompts.gen_commit_message").prompt,
        diagnostics = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
      },
    },
  },
  keys = {
    {
      "<leader>an",
      function()
        require("sidekick").nes_jump_or_apply()
      end,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    -- {
    --   "<c-L>",
    --   function()
    --    require("sidekick.cli").toggle()
    --   end,
    --   desc = "Sidekick Toggle",
    --   mode = { "n", "t", "i", "x" },
    -- },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function()
        require("util.sidekick_sessions").select()
      end,
      desc = "Select CLI Session",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Detach a CLI Session",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File",
    },
    {
      "<leader>ai",
      function()
        require("sidekick.cli").send({ prompt = "diagnostics" })
      end,
      desc = "Insert Diagnostics",
    },
    {
      "<leader>av",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    -- Open Codex directly
    {
      "<leader>ac",
      function()
        require("util.sidekick_sessions").toggle_codex()
      end,
      desc = "Sidekick Toggle Codex",
    },
    {
      "<leader>aC",
      function()
        require("util.sidekick_sessions").new_codex()
      end,
      desc = "Sidekick New Codex Session",
    },
  },
}
