local M = {}

local enabled = false
local previous

local function notify(message)
  vim.notify(message, vim.log.levels.INFO, { title = "Clipboard" })
end

local function reload_provider()
  vim.cmd("unlet! g:loaded_clipboard_provider")
  vim.cmd("runtime autoload/provider/clipboard.vim")
end

function M.enable()
  if enabled then
    return true
  end

  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if not ok then
    vim.notify("OSC 52 requires Neovim 0.10 or newer", vim.log.levels.WARN, { title = "Clipboard" })
    return false
  end

  previous = {
    provider = vim.deepcopy(vim.g.clipboard),
    option = vim.opt.clipboard:get(),
  }
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
  vim.opt.clipboard = "unnamedplus"
  reload_provider()
  enabled = true
  notify("OSC 52 clipboard enabled")
  return true
end

function M.disable()
  if not enabled then
    return false
  end

  vim.g.clipboard = previous.provider
  vim.opt.clipboard = previous.option
  reload_provider()
  previous = nil
  enabled = false
  notify("OSC 52 clipboard disabled")
  return false
end

function M.toggle()
  if enabled then
    return M.disable()
  end
  return M.enable()
end

function M.is_enabled()
  return enabled
end

return M
