return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "s1n7ax/nvim-window-picker" },
  opts = {
    window = {
      mappings = {
        ["<Tab>"] = "focus_preview",
        ["l"] = "open",
        ["s"] = "open_split",
        ["S"] = "none",
        ["v"] = "open_vsplit",
      },
    },
  }
}
