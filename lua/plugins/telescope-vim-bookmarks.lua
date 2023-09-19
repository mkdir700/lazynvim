return {
  "tom-anders/telescope-vim-bookmarks.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "MattesGroeger/vim-bookmarks" },
  },
  event = "VeryLazy",
  keys = {
    {
      "<leader>sm",
      function()
        require("telescope").extensions.vim_bookmarks.all()
      end,
      mode = { "n" },
      desc = "Bookmarks(all)",
    },
    {
      "<leader>bm",
      function()
        require("telescope").extensions.vim_bookmarks.current_file()
      end,
      mode = { "n" },
      desc = "Bookmarks(current)",
    },
  },
  config = function()
    require("telescope").load_extension("vim_bookmarks")
  end,
}
