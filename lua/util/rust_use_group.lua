local M = {}

local function comma_appended_identifier(error_node)
  local expect_comma = true
  local identifiers = 0

  for index = 0, error_node:child_count() - 1 do
    local child = error_node:child(index)
    if expect_comma then
      if child:type() ~= "," or child:named() then
        return false
      end
    else
      if child:type() ~= "identifier" or not child:named() then
        return false
      end
      identifiers = identifiers + 1
    end
    expect_comma = not expect_comma
  end

  return identifiers > 0 and expect_comma
end

local function shorthand_parts(use_node)
  local argument = use_node:field("argument")[1]
  if not argument or argument:type() ~= "scoped_identifier" then
    return nil
  end

  local name = argument:field("name")[1]
  if not name or name:type() ~= "identifier" then
    return nil
  end

  local _, _, argument_end_row, argument_end_col = argument:range()
  local error_node
  local semicolon

  for index = 0, use_node:child_count() - 1 do
    local child = use_node:child(index)
    local start_row, start_col = child:start()
    if child:type() == "ERROR" and start_row == argument_end_row and start_col == argument_end_col then
      error_node = child
    elseif child:type() == ";" then
      semicolon = child
    end
  end

  if not error_node or not semicolon or not comma_appended_identifier(error_node) then
    return nil
  end

  local name_row, name_col = name:start()
  local semicolon_row, semicolon_col = semicolon:start()
  if name_row ~= semicolon_row then
    return nil
  end

  return name_row, name_col, semicolon_col
end

function M.expand_at_cursor(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].filetype ~= "rust" or vim.api.nvim_get_current_buf() ~= bufnr then
    return false
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "rust")
  if not ok or not parser then
    return false
  end

  local trees = parser:parse()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local node = trees[1]:root():named_descendant_for_range(row, cursor[2], row, cursor[2])
  while node and node:type() ~= "use_declaration" do
    node = node:parent()
  end
  if not node then
    return false
  end

  local line, name_col, semicolon_col = shorthand_parts(node)
  if not line then
    return false
  end

  local imported = vim.api.nvim_buf_get_text(bufnr, line, name_col, line, semicolon_col, {})[1]
  vim.api.nvim_buf_set_text(bufnr, line, name_col, line, semicolon_col, { "{" .. imported .. "}" })

  local cursor_shift = cursor[2] >= semicolon_col and 2 or 1
  vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + cursor_shift })
  return true
end

function M.setup()
  local group = vim.api.nvim_create_augroup("RustUseGroupShorthand", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    desc = "Group comma-appended Rust imports",
    callback = function(event)
      M.expand_at_cursor(event.buf)
    end,
  })
end

return M
