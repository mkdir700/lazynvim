-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.o.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize"
vim.o.swapfile = false

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false

require("config.neovide")

-- "github" | "supermaven"
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
