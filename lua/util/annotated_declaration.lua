local M = {}

local declaration_types = {
  rust = {
    struct_item = true,
    enum_item = true,
    union_item = true,
    trait_item = true,
    impl_item = true,
    mod_item = true,
    function_item = true,
  },
  python = {
    class_definition = true,
    function_definition = true,
  },
}

local function declaration_node(bufnr)
  local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype
  local types = declaration_types[language]
  if not types then
    return nil, language
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local node = vim.treesitter.get_node({ buf = bufnr, pos = { cursor[1] - 1, cursor[2] } })
  while node do
    if types[node:type()] then
      return node, language
    end
    node = node:parent()
  end
end

function M.range(bufnr)
  local node, language = declaration_node(bufnr)
  if not node then
    return nil
  end

  if language == "python" and node:parent() and node:parent():type() == "decorated_definition" then
    node = node:parent()
    return { node:range() }
  end

  local start_row, start_col, end_row, end_col = node:range()
  if language == "rust" then
    local previous = node:prev_named_sibling()
    while previous and previous:type() == "attribute_item" do
      start_row, start_col = previous:range()
      previous = previous:prev_named_sibling()
    end
  end

  return { start_row, start_col, end_row, end_col }
end

function M.select()
  local range = M.range(0)
  if not range then
    return
  end

  local start_row, start_col, end_row, end_col = unpack(range)
  if end_col == 0 then
    end_row = end_row - 1
    end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] + 1
  end

  if vim.api.nvim_get_mode().mode:match("^[vV]") then
    vim.cmd("normal! <esc>")
  end
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd.normal({ "v", bang = true })
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
end

return M
