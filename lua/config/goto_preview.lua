local M = {}

local function position_on_file_before_line_number(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = vim.api.nvim_get_current_line()
  local byte_index = cursor[2] + 1

  if not line:sub(byte_index, byte_index):match("%d") then
    return
  end

  local number_start = byte_index
  while number_start > 1 and line:sub(number_start - 1, number_start - 1):match("%d") do
    number_start = number_start - 1
  end

  local colon_index = number_start - 1
  if colon_index > 1 and line:sub(colon_index, colon_index) == ":" then
    vim.api.nvim_win_set_cursor(win, { cursor[1], colon_index - 2 })
  end
end

function M.resolve_file_under_cursor()
  local source_win = vim.api.nvim_get_current_win()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_cursor = vim.api.nvim_win_get_cursor(source_win)
  local target

  local ok = pcall(vim.api.nvim_win_call, source_win, function()
    position_on_file_before_line_number(source_win)
    vim.cmd.normal({ args = { "gF" }, bang = true })
    local target_buf = vim.api.nvim_get_current_buf()
    target = {
      buf = target_buf,
      cursor = vim.api.nvim_win_get_cursor(source_win),
      path = vim.fs.normalize(vim.api.nvim_buf_get_name(target_buf)),
    }
  end)

  if vim.api.nvim_win_is_valid(source_win) and vim.api.nvim_buf_is_valid(source_buf) then
    vim.api.nvim_win_call(source_win, function()
      local noautocmd = vim.api.nvim_buf_get_name(source_buf) == "" and "noautocmd " or ""
      vim.cmd(noautocmd .. "buffer " .. source_buf)
      vim.api.nvim_win_set_cursor(source_win, source_cursor)
    end)
  end

  if not ok or not target or target.path == "" or vim.fn.filereadable(target.path) ~= 1 then
    return nil
  end

  return target
end

function M.open_file_preview(target)
  local preview = Snacks.win({
    buf = target.buf,
    enter = true,
    backdrop = false,
    border = "rounded",
    width = math.min(120, vim.o.columns - 4),
    height = math.min(15, vim.o.lines - 4),
    title = vim.fn.fnamemodify(target.path, ":."),
    title_pos = "left",
    wo = {
      number = true,
      relativenumber = false,
      signcolumn = "yes",
      wrap = false,
    },
  })

  vim.api.nvim_win_set_cursor(preview.win, target.cursor)
  return preview
end

function M.goto_preview()
  local target = M.resolve_file_under_cursor()
  if target then
    return M.open_file_preview(target)
  end

  require("goto-preview").goto_preview_definition()
end

return M
