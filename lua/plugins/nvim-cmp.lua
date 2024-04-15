return {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local luasnip = require("luasnip")
    local cmp = require("cmp")

    opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))

    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    -- 检查当前光标的后一位是否是 pair
    -- @treturn bool
    local function is_next_char_pair()
      local line = vim.api.nvim_get_current_line()
      local _, col = unpack(vim.api.nvim_win_get_cursor(0))
      local after = line:sub(col + 1, -1)
      local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
      for _, pair in ipairs(closers) do
        if after:sub(1, #pair) == pair then
          return true
        end
      end
      return false
    end

    -- 跳出 pair
    local function escape_pair()
      local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
      local line = vim.api.nvim_get_current_line()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local after = line:sub(col + 1, -1)
      local closer_col = #after + 1
      local closer_i = nil
      for i, closer in ipairs(closers) do
        local cur_index, _ = after:find(closer)
        if cur_index and (cur_index < closer_col) then
          closer_col = cur_index
          closer_i = i
        end
      end
      if closer_i then
        vim.api.nvim_win_set_cursor(0, { row, col + closer_col })
      else
        vim.api.nvim_win_set_cursor(0, { row, col + 1 })
      end
    end

    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<Tab>"] = cmp.mapping(function(fallback)
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").accept()
        elseif is_next_char_pair() then
          escape_pair()
        elseif cmp.visible() then
          -- You could replace select_next_item() with confirm({ select = true })
          -- to get VS Code autocompletion behavior
          cmp.select_next_item()
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- this way you will only jump inside the snippet region
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    })

    -- NOTE: 在选择一个函数或者方法时，自动补充括号
    -- LazyVim 中已经有了这个功能，所以这里不需要
    -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
