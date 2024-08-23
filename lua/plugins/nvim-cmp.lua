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

return {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local luasnip = require("luasnip")
    local cmp = require("cmp")

    opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))

    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<Tab>"] = cmp.mapping(function(fallback)
        -- chose fittencode or copilot if available
        local ok, fittencode, copilot
        ok, fittencode = pcall(require, "fittencode.engines.inline")
        if ok and fittencode.has_suggestions() then
          fittencode.accept_all_suggestions()
          return
        end

        ok, copilot = pcall(require, "copilot.suggestion")
        if ok and copilot.is_visible() then
          copilot.accept()
          return
        end

        if is_next_char_pair() then
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

    -- https://github.com/LazyVim/LazyVim/releases/tag/v10.20.0
    -- v10.20.0 版本后对于 python 默认开启了括号补全，但是我感觉不好用，所以这里给移除
    opts.auto_brackets = opts.auto_brackets or {}
    for i, bracket in ipairs(opts.auto_brackets) do
      if bracket == "python" then
        table.remove(opts.auto_brackets, i)
        break
      end
    end
    -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
