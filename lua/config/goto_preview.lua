local M = {}

local function looks_like_file_reference(value)
  return value:find("[/\\]") ~= nil or value:match("%.[%w_-]+$") ~= nil
end

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
    if not looks_like_file_reference(vim.fn.expand("<cfile>")) then
      return
    end
    vim.cmd.normal({ args = { "gF" }, bang = true })
    local target_buf = vim.api.nvim_get_current_buf()
    target = {
      buf = target_buf,
      cursor = vim.api.nvim_win_get_cursor(source_win),
      path = vim.fs.normalize(vim.api.nvim_buf_get_name(target_buf)),
      source_win = source_win,
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

local split_commands = {
  left = "leftabove vsplit",
  right = "rightbelow vsplit",
  above = "leftabove split",
  below = "rightbelow split",
}

function M.dock_file_preview(preview, direction)
  local command = assert(split_commands[direction], "invalid preview direction: " .. tostring(direction))
  local source_win = preview.source_win
  if not (source_win and vim.api.nvim_win_is_valid(source_win)) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(preview.win)
  local cursor = vim.api.nvim_win_get_cursor(preview.win)
  vim.api.nvim_win_close(preview.win, true)
  vim.api.nvim_set_current_win(source_win)
  vim.cmd(command)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, cursor)
end

local function attach_dock_keymaps(preview, buf)
  local keymaps = {
    H = "left",
    J = "below",
    K = "above",
    L = "right",
  }
  for key, direction in pairs(keymaps) do
    vim.keymap.set("n", "<c-w>" .. key, function()
      M.dock_file_preview(preview, direction)
    end, { buffer = buf, desc = "Dock preview " .. direction })
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(preview.win),
    once = true,
    callback = function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      for key in pairs(keymaps) do
        pcall(vim.keymap.del, "n", "<c-w>" .. key, { buffer = buf })
      end
    end,
  })
end

function M.attach_definition_preview(buf, win)
  local preview = {
    win = win,
    source_win = M.definition_source_win,
  }
  M.definition_source_win = nil
  attach_dock_keymaps(preview, buf)
  return preview
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

  preview.source_win = target.source_win
  vim.api.nvim_win_set_cursor(preview.win, target.cursor)
  attach_dock_keymaps(preview, target.buf)

  return preview
end

function M.goto_preview()
  local target = M.resolve_file_under_cursor()
  if target then
    return M.open_file_preview(target)
  end

  M.definition_source_win = vim.api.nvim_get_current_win()
  require("goto-preview").goto_preview_definition()
end

return M
