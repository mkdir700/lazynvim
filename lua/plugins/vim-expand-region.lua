return {
  "terryma/vim-expand-region",
  keys = {"v", "V"},
  config = function()
    vim.api.nvim_set_keymap("v", "v", "<Plug>(expand_region_expand)", {})
    vim.api.nvim_set_keymap("v", "V", "<Plug>(expand_region_shrink)", {})
  end,
}
