local sidekick_reader_root = "/Users/mark/MyProjects/sidekick-reader.nvim"
local sidekick_reader_registry = vim.fs.joinpath(vim.fn.stdpath("state"), "hajimi")

return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        config = function(terminal)
          if terminal._sidekick_reader_wrapped then
            return
          end
          terminal._sidekick_reader_wrapped = true
          local original_show = terminal.show
          local original_hide = terminal.hide
          local original_close = terminal.close

          local function pane(self)
            local resolver = require("util.sidekick_reader")
            self._sidekick_reader_pane_id = self._sidekick_reader_pane_id
              or resolver.terminal_pane(self)
              or resolver.active_pane(sidekick_reader_registry)
            return self._sidekick_reader_pane_id
          end

          terminal.show = function(self, ...)
            local result = original_show(self, ...)
            local pane_id = pane(self)
            if pane_id and self.win then
              require("sidekick_reader").sidekick_show(pane_id, self.win, self)
            end
            return result
          end
          terminal.hide = function(self, ...)
            local pane_id = pane(self)
            if pane_id then
              require("sidekick_reader").sidekick_hide(pane_id)
            end
            return original_hide(self, ...)
          end
          terminal.close = function(self, ...)
            local pane_id = pane(self)
            if pane_id then
              require("sidekick_reader").sidekick_close(pane_id)
            end
            return original_close(self, ...)
          end
        end,
        split = {
          width = 60,
        },
        keys = {
          sidekick_reader_toggle = {
            "<C-]>",
            function()
              local pane = require("util.sidekick_reader").active_pane(sidekick_reader_registry)
              if not pane then
                return vim.notify("Sidekick Reader: cannot resolve this Sidekick Codex session", vim.log.levels.WARN)
              end
              local current = vim.api.nvim_get_current_win()
              local terminal
              local ok, states = pcall(require("sidekick.cli.state").get, { attached = true, name = "codex" })
              if ok then
                for _, state in ipairs(states) do
                  if state.terminal and state.terminal.win == current then
                    terminal = state.terminal
                    break
                  end
                end
              end
              require("sidekick_reader").focus(pane, current, terminal)
            end,
            mode = { "n", "t" },
            desc = "Focus Sidekick Reader",
          },
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
          cmd = {
            "node",
            vim.fs.joinpath(sidekick_reader_root, "scripts", "bridge.mjs"),
            "launch",
            "--dangerously-bypass-approvals-and-sandbox",
          },
          env = { SIDEKICK_READER_REGISTRY_DIR = sidekick_reader_registry },
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
