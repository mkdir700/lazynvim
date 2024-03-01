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

      -- gF 根据 traceback 跳转到对应文件行号
      local function traceback_jump()
        -- {
        --   argv = { "nvim", "--embed", "+2", "main.py" },
        --   files = { "/home/xyz/max-hmi-server/main.py" },
        --   force_block = false,
        --   guest_cwd = "/home/xyz/max-hmi-server",
        --   response_pipe = "/run/user/1000/nvim.1421421.0",
        --   stdin = {}
        -- }
        local ok, _ = pcall(require, "flatten")
        if not ok then
          vim.notify("flatten.nvim not found", "error")
          return
        end
        local edit_files = require("flatten.core").edit_files
        local traceback = vim.fn.getline(".")
        local file, line = traceback:match('File "(.+)", line (%d+)')
        if file and line then
          edit_files({
            files = { file },
            guest_cwd = vim.fn.fnamemodify(file, ":h"),
            argv = { "nvim", "--embed", "+" .. line, file },
            force_block = false,
            stdin = {},
            response_pipe = vim.fn.tempname(),
          })
        end
      end
      vim.keymap.set("n", "gF", function()
        traceback_jump()
      end, opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
