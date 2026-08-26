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
        {
          "<leader>uy",
          function()
            require("util.osc52_clipboard").toggle()
          end,
          desc = "Toggle OSC 52 Clipboard",
        },
        {
          "p",
          function()
            if not require("util.smart_paste").into_empty_braces() then
              require("yanky").put("p", false)
            end
          end,
          mode = "n",
          desc = "Put text after cursor",
        },
        { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
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
}
