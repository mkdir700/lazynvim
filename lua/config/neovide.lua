if not vim.g.neovide then
  return
end

-- Typography and window appearance
vim.o.guifont = "JetVictor Mono:h14"
vim.g.neovide_scale_factor = 1.0
vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 8
vim.g.neovide_padding_right = 8
vim.g.neovide_padding_left = 8
vim.g.neovide_opacity = 0.95
vim.g.neovide_window_blurred = true
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
vim.g.neovide_remember_window_size = true
vim.g.neovide_confirm_quit = true

-- Motion
vim.g.neovide_position_animation_length = 0.12
vim.g.neovide_scroll_animation_length = 0.2
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.5
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_unfocused_outline_width = 0.125
vim.g.neovide_cursor_vfx_mode = "ripple"
vim.g.neovide_hide_mouse_when_typing = true

local function change_scale(delta)
  vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, vim.g.neovide_scale_factor + delta))
end

vim.keymap.set({ "n", "v", "i", "c" }, "<D-=>", function()
  change_scale(0.1)
end, { desc = "Increase GUI scale" })
vim.keymap.set({ "n", "v", "i", "c" }, "<D-+>", function()
  change_scale(0.1)
end, { desc = "Increase GUI scale" })
vim.keymap.set({ "n", "v", "i", "c" }, "<D-->", function()
  change_scale(-0.1)
end, { desc = "Decrease GUI scale" })
vim.keymap.set({ "n", "v", "i", "c" }, "<D-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Reset GUI scale" })

vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy" })
vim.keymap.set({ "n", "v", "i", "c", "t" }, "<D-v>", function()
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Paste" })
vim.keymap.set({ "n", "v", "i" }, "<D-s>", "<cmd>write<cr>", { desc = "Save" })
