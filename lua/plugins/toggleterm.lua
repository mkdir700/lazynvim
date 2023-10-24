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
      on_create = function(t)
        -- NOTE: 在 venv-selector 中被设置 VIRTUAL_ENV 环境变量
        local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
        local is_windows = vim.loop.os_uname().version:match("Windows")
        -- 是否为首次打开终端
        if virtual_env then
          if is_windows then
            t:send({ string.format("%s/Scripts/activate", virtual_env) })
            t:send({ "cls" })
          else
            -- 打开终端后，自动执行激活虚拟环境命令
            -- 如果当前终端是 fish
            if vim.o.shell:find("fish") then
              t:send({ string.format("source %s/bin/activate.fish", virtual_env) })
            else
              -- 如果当前终端是 bash
              t:send({ string.format("source %s/bin/activate", virtual_env) })
            end
            t:send({ "clear" })
          end
        end
      end,
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
