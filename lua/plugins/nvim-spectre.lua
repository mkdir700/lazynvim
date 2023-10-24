-- vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
--     desc = "Toggle Spectre"
-- })
-- vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
--     desc = "Search current word"
-- })
-- vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
--     desc = "Search current word"
-- })
-- vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
--     desc = "Search on current file"
-- })

return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  keys = {
    {
      "<leader>sr",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Search on current file",
    },
    {
      "<leader>aR",
      function()
        require("spectre").open_visual()
      end,
      desc = "Search in files",
    },
  },
  config = function()
    require("spectre").setup({
      mapping = {
        ["run_current_replace"] = {
          map = "<C-Enter>",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
      },
    })
  end,
}
