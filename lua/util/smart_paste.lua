local M = {}

local function common_indent(lines)
  local shortest
  for _, line in ipairs(lines) do
    if line:find("%S") then
      local indent = line:match("^%s*") or ""
      if shortest == nil or #indent < #shortest then
        shortest = indent
      end
    end
  end
  return shortest or ""
end

function M.into_empty_braces()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, column = cursor[1], cursor[2]
  local line = vim.api.nvim_get_current_line()

  if line:sub(column + 1, column + 1) ~= "{" then
    return false
  end

  local after_brace = line:sub(column + 2)
  if not after_brace:match("^%s*}") then
    return false
  end

  local register = vim.v.register
  local lines = vim.fn.getreg(register, 1, true)
  if type(lines) ~= "table" or #lines < 2 then
    return false
  end

  local base_indent = line:match("^%s*") or ""
  local child_indent = base_indent .. string.rep(" ", vim.fn.shiftwidth())
  local pasted_indent = common_indent(lines)
  local replacement = { line:sub(1, column + 1) }

  for _, pasted_line in ipairs(lines) do
    local content = pasted_line:sub(#pasted_indent + 1)
    replacement[#replacement + 1] = content == "" and "" or child_indent .. content
  end

  replacement[#replacement + 1] = base_indent .. after_brace:gsub("^%s*", "")
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, replacement)
  vim.api.nvim_win_set_cursor(0, { row + 1, #child_indent })
  return true
end

return M
