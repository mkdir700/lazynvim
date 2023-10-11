return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.6
        end
      end,
      open_mapping = [[<c-\>]],
      autochdir = true,
      auto_scroll = false,
    })

    -- Set terminal keymaps
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0, noremap = true }
      local bufname = vim.fn.bufname("%")
      -- 插入模式下 <C-h> 向左删除字符
      vim.keymap.set("t", "<C-h>", "<BS>", opts)

      if not string.find(bufname, "lazygit") then
        -- 只在打开非 lazygit 终端时设置映射
        -- 在正常模式下 <esc> toggle 终端
        vim.keymap.set("n", "<esc>", "<CMD>ToggleTerm<CR>", opts)
        -- 回到刚才来的窗口
        vim.keymap.set({ "t", "n" }, "<C-k>", "<Cmd>wincmd p<CR>", opts)
      end
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
