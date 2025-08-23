return {
  -- 为什么不使用 LazyVim 配置的方式，而是使用插件管理器的方式？
  -- 占用了 gp 和 gP 两个键位，这两个键位在我配置中用于快速预览方法定义和引用。
  {
    "gbprod/yanky.nvim",
    keys = function()
      return {
        {
          "<leader>sp",
          function()
            require("telescope").extensions.yank_history.yank_history({})
          end,
          desc = "Open Yank History",
        },
        -- { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
        -- { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
        -- { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
        { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
        { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
        { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
        { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
        { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
        { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
        { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
        { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
        { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
        { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
        { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
        { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
      }
    end,
  },

  -- OSC52 复制到外部剪贴板（tmux/SSH 场景）
  {
    "ojroques/nvim-osc52",
    cond = function()
      return os.getenv("SSH_TTY") or os.getenv("WSL_DISTRO_NAME")
    end,
    config = function()
      local osc52 = require("osc52")
      osc52.setup({
        max_length = 0, -- 不限制
        silent = true,
        trim = false,
      })

      local function copy(lines, _)
        osc52.copy(table.concat(lines, "\n"))
      end

      local function paste()
        -- 优先仍然走系统寄存器
        return { vim.fn.getreg('"'), vim.fn.getregtype('"') }
      end

      -- 当检测到无法调用 Windows 剪贴板时，自动把 "+ provider 指向 OSC52
      local in_wsl = (vim.fn.has("wsl") == 1)
      local clip_ok = in_wsl and (vim.fn.executable("clip.exe") == 1 or vim.fn.executable("win32yank.exe") == 1)

      if not clip_ok then
        vim.g.clipboard = {
          name = "osc52",
          copy = { ["+"] = copy, ["*"] = copy },
          paste = { ["+"] = paste, ["*"] = paste },
        }
      end
    end,
  },
}
