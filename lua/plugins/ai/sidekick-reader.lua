if vim.env.NVIM_ENABLE_SIDEKICK_READER == "0" then
  return {}
end

local local_root = vim.env.SIDEKICK_READER_DIR
if local_root == "" then
  local_root = nil
end

local root = local_root or vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "sidekick-reader.nvim")
local registry = vim.env.SIDEKICK_READER_REGISTRY_DIR
if not registry or registry == "" then
  registry = vim.fs.joinpath(vim.fn.stdpath("state"), "hajimi")
end

return {
  {
    "mkdir700/sidekick-reader.nvim",
    dir = local_root,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      registry_dir = registry,
      layout = "stacked",
      viewer_ratio = 0.8,
    },
  },
  {
    "folke/sidekick.nvim",
    dependencies = { "mkdir700/sidekick-reader.nvim" },
    opts = function(_, opts)
      local win = opts.cli.win
      local original_config = win.config

      win.config = function(terminal)
        if original_config then
          original_config(terminal)
        end
        require("util.sidekick_reader").attach(terminal, registry)
      end

      win.keys.sidekick_reader_toggle = {
        "<C-]>",
        function()
          require("util.sidekick_reader").focus(registry)
        end,
        mode = { "n", "t" },
        desc = "Focus Sidekick Reader",
      }

      opts.cli.tools.codex = {
        cmd = {
          "node",
          vim.fs.joinpath(root, "scripts", "bridge.mjs"),
          "launch",
          "--dangerously-bypass-approvals-and-sandbox",
        },
        env = { SIDEKICK_READER_REGISTRY_DIR = registry },
      }
    end,
  },
}
