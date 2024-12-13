-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldlevel = 10
vim.wo.foldminlines = 1
vim.wo.foldnestmax = 10
vim.wo.foldtext =
  [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']]

vim.o.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize"
vim.o.swapfile = false

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false

-- neovide options
vim.g.neovide_cursor_animation_length = 0.03
vim.g.neovide_cursor_trail_length = 0.2
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_vfx_mode = "ripple"
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_unfocused_outline_width = 0.125

-- neovide - window
vim.g.neovide_window_blurred = true
-- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
vim.g.neovide_transparency = 0.9
-- vim.g.transparency = 0.8
-- vim.g.neovide_background_color = "#0f1117" .. alpha()
vim.g.experimental_layer_grouping = false

-- "github" | "fittencode"
vim.g.code_copilot = "fittencode"
-- -- LSP Server to use for Python.
-- -- Set to "basedpyright" to use basedpyright instead of pyright.
-- vim.g.lazyvim_python_lsp = "pyright"
-- -- Set to "ruff_lsp" to use the old LSP implementation version.

-- 判断是否从 vscode 启动，如果是则设置为 true
-- 用于在启动时加载不同的配置
if vim.fn.getenv("VSCODE_INJECTION") ~= vim.NIL then
  vim.g.vscode = true
end
