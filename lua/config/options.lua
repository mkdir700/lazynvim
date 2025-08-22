-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

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

-- "github" | "fittencode" | "supermaven" | "claudecode"
vim.g.code_copilot = "supermaven"

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

vim.cmd([[
set tagfunc=v:lua.vim.lsp.tagfunc
set jumpoptions+=stack
]])

vim.g.snacks_animate = true

vim.filetype.add({
  extension = {
    ["http"] = "http",
  },
})

vim.g.lazyvim_picker = "snacks"

-- 让 y/p 默认走系统剪贴板
vim.opt.clipboard = "unnamedplus"
