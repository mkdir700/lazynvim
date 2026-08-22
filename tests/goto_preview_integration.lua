local source_win = vim.api.nvim_get_current_win()
local source_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(source_buf, vim.fn.getcwd() .. "/.gp-preview-sidekick")
vim.bo[source_buf].buftype = "nofile"
vim.api.nvim_set_current_buf(source_buf)
local source_line = "// │ tests/goto_preview_spec.lua:50"
vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { source_line })
local line_number_col = assert(source_line:find("50", 1, true)) - 1
vim.api.nvim_win_set_cursor(source_win, { 1, line_number_col + 1 })
vim.o.undofile = false

vim.cmd("leftabove vsplit")
local left_win = vim.api.nvim_get_current_win()
local left_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_win_set_buf(left_win, left_buf)
vim.api.nvim_set_current_win(source_win)

local mapping = vim.fn.maparg("gp", "n", false, true)
assert(mapping.desc == "Preview File or Definition", "gp mapping was not loaded")

local keys = vim.api.nvim_replace_termcodes("gp", true, false, true)
vim.api.nvim_feedkeys(keys, "mx", false)

assert(
  vim.wait(3000, function()
    local current_win = vim.api.nvim_get_current_win()
    return current_win ~= source_win and vim.api.nvim_win_get_config(current_win).relative ~= ""
  end),
  "gp did not open a floating preview"
)

local preview_win = vim.api.nvim_get_current_win()
local preview_buf = vim.api.nvim_win_get_buf(preview_win)
local expected_path = vim.uv.fs_realpath("tests/goto_preview_spec.lua")

assert(vim.api.nvim_win_get_buf(source_win) == source_buf, "gp replaced the source window")
assert(vim.api.nvim_win_get_buf(left_win) == left_buf, "gp changed the other editing window")
assert(vim.api.nvim_buf_get_name(preview_buf) == expected_path, "gp previewed the wrong file")
assert(vim.api.nvim_win_get_cursor(preview_win)[1] == 50, "gp did not jump to the requested line")

local regular_windows = vim.tbl_filter(function(win)
  return vim.api.nvim_win_get_config(win).relative == ""
end, vim.api.nvim_tabpage_list_wins(0))
assert(#regular_windows == 2, "gp changed the two-column layout")

print("gp integration: cursor on line number opened line 50 and preserved the two-column layout")
