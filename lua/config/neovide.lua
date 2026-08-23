if not vim.g.neovide then
  return
end

-- Typography and window appearance
vim.o.guifont = "JetVictor Mono:h14"

-- Window
vim.g.neovide_scale_factor = 1.0
vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 8
vim.g.neovide_padding_right = 8
vim.g.neovide_padding_left = 8
vim.g.neovide_remember_window_size = true
vim.g.neovide_confirm_quit = true

-- Cursor
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_short_animation_length = 0.03
vim.g.neovide_cursor_trail_size = 0.6
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_unfocused_outline_width = 0.125

-- Cursor VFX
vim.g.neovide_cursor_vfx_mode = "sonicboom"
vim.g.neovide_cursor_vfx_opacity = 150.0
vim.g.neovide_cursor_vfx_particle_lifetime = 0.35
vim.g.neovide_cursor_vfx_particle_density = 0.5
vim.g.neovide_cursor_vfx_particle_speed = 8.0

-- Scroll
vim.g.neovide_scroll_animation_length = 0.15
vim.g.neovide_scroll_animation_far_lines = 1

-- Window animation
vim.g.neovide_position_animation_length = 0.12

-- Floating windows
vim.g.neovide_floating_corner_radius = 0.4
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- macOS
vim.g.neovide_opacity = 0.95
vim.g.neovide_normal_opacity = 0.95
vim.g.neovide_window_blurred = true

-- UX
vim.g.neovide_hide_mouse_when_typing = true

-- Progress
vim.g.neovide_progress_bar_enabled = true
vim.g.neovide_progress_bar_height = 2.0
vim.g.neovide_progress_bar_hide_delay = 0.3

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
