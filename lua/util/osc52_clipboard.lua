local M = {}

local enabled = false
local previous
local group_name = "Osc52Clipboard"

local function notify(message)
  vim.notify(message, vim.log.levels.INFO, { title = "Clipboard" })
end

local function reload_provider()
  vim.cmd("unlet! g:loaded_clipboard_provider")
  vim.cmd("runtime autoload/provider/clipboard.vim")
end

local function start_yank_forwarding(copy)
  local group = vim.api.nvim_create_augroup(group_name, { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      if vim.v.event.operator and vim.v.event.operator ~= "y" then
        return
      end
      local lines = vim.v.event.regcontents
      if type(lines) ~= "table" then
        local register = vim.v.event.regname ~= "" and vim.v.event.regname or '"'
        lines = vim.fn.getreg(register, 1, true)
      end
      copy(lines)
    end,
  })
end

local function stop_yank_forwarding()
  pcall(vim.api.nvim_del_augroup_by_name, group_name)
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
  local function paste_local()
    return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste_local,
      ["*"] = paste_local,
    },
  }
  vim.opt.clipboard = ""
  reload_provider()
  start_yank_forwarding(vim.g.clipboard.copy["+"])
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
  stop_yank_forwarding()
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
