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

-- Neovim 0.12 can try to underline stale diagnostics past the end of a reloaded file.
-- This mirrors the upstream 0.13 fix and can be removed once 0.12 is no longer supported.
if vim.fn.has("nvim-0.13") == 0 then
  local underline = vim.diagnostic.handlers.underline
  local show = underline.show

  underline.show = function(namespace, bufnr, diagnostics, opts)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    diagnostics = vim.tbl_filter(function(diagnostic)
      return diagnostic.lnum < line_count
    end, diagnostics)
    show(namespace, bufnr, diagnostics, opts)
  end
end

vim.cmd([[
set tagfunc=v:lua.vim.lsp.tagfunc
set jumpoptions+=stack,clean
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
