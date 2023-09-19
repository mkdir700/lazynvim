return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "s1n7ax/nvim-window-picker" },
  opts = {
    window = {
      mappings = {
        ["<Tab>"] = "focus_preview",
        ["l"] = "open",
        ["S"] = "none",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
      },
    },

    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        always_show = { ".git", "LICENSE", "README.md" },
        hide_by_name = {
          ".pytest_cache",
          ".mypy_cache",
          "__pycache__",
        },
        -- hide_by_pattern = { -- uses glob style patterns
        --   ".pytest_cache/*",
        -- },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          ".DS_Store",
          "thumbs.db",
          ".idea",
          ".ruff_cache",
        },
      },
    },
  },
}
