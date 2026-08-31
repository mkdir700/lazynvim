local M = {}

local state = {
  command = nil,
  current = "",
  rime_mode = "",
  running = false,
  last_check = 0,
  app_id = nil,
  status_dir = nil,
}

local refresh_interval = 500

local function detect_app_id()
  if vim.g.neovide then
    return "com.neovide.neovide"
  end

  if vim.uv.os_uname().sysname == "Linux" then
    return "fcitx5-rime"
  end

  local terminal_apps = {
    Apple_Terminal = "com.apple.Terminal",
    ["iTerm.app"] = "com.googlecode.iterm2",
    WezTerm = "com.github.wez.wezterm",
    ghostty = "com.mitchellh.ghostty",
    kitty = "net.kovidgoyal.kitty",
    Alacritty = "org.alacritty",
  }
  return terminal_apps[os.getenv("TERM_PROGRAM") or ""]
end

local function status_path(app_id, directory)
  local safe_app_id = (app_id or ""):gsub("[^%w._-]", "_")
  return directory .. "/rime-input-method-" .. safe_app_id .. ".status"
end

local function read_rime_mode(input_method)
  local name = (input_method or ""):lower()
  if not state.app_id or not (name:find("squirrel", 1, true) or name:find("rime", 1, true)) then
    return ""
  end

  local path = status_path(state.app_id, state.status_dir)
  if vim.fn.filereadable(path) ~= 1 then
    return ""
  end

  local mode = vim.trim(vim.fn.readfile(path, "", 1)[1] or "")
  if mode == "ascii" or mode == "nascii" then
    return mode
  end
  return ""
end

local function find_command()
  if
    (vim.fn.has("wsl") == 1 or vim.fn.has("win32") == 1)
    and vim.fn.executable("AIMSwitcher.exe") == 1
  then
    return { "AIMSwitcher.exe", "--imm" }
  end

  local candidates = {
    { executable = "macism", command = { "macism" } },
    { executable = "fcitx5-remote", command = { "fcitx5-remote", "-n" } },
    { executable = "ibus", command = { "ibus", "engine" } },
    { executable = "im-select", command = { "im-select" } },
  }

  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate.executable) == 1 then
      return candidate.command
    end
  end
end

function M.label(input_method, rime_mode)
  local name = vim.trim(input_method or ""):lower()
  if name == "" then
    return ""
  end

  if name:find("squirrel", 1, true) or name:find("rime", 1, true) then
    return rime_mode == "ascii" and "EN" or "中"
  end

  if name == "0" then
    return "EN"
  end

  if name == "1025" then
    return "中"
  end

  if
    name == "1033"
    or name:find("keylayout", 1, true)
    or name:find("keyboard-us", 1, true)
    or name:find("xkb:us", 1, true)
  then
    return "EN"
  end

  if name:find("scim", 1, true) or name:find("pinyin", 1, true) or name:find("wubi", 1, true) then
    return "中"
  end

  return "IM"
end

function M.refresh(force)
  if not state.command or state.running then
    return
  end

  local now = vim.uv.now()
  if not force and now - state.last_check < refresh_interval then
    return
  end

  state.running = true
  state.last_check = now
  vim.system(
    state.command,
    { text = true },
    vim.schedule_wrap(function(result)
      state.running = false
      if result.code ~= 0 then
        return
      end

      local current = vim.trim(result.stdout or "")
      local rime_mode = read_rime_mode(current)
      if current ~= state.current or rime_mode ~= state.rime_mode then
        state.current = current
        state.rime_mode = rime_mode
        local lualine = package.loaded["lualine"]
        if type(lualine) == "table" and type(lualine.refresh) == "function" then
          lualine.refresh({ place = { "statusline" } })
        else
          vim.cmd.redrawstatus()
        end
      end
    end)
  )
end

function M.component()
  M.refresh(false)
  return M.label(state.current, state.rime_mode)
end

function M.available()
  return state.command ~= nil
end

function M.is_chinese()
  return M.label(state.current, state.rime_mode) == "中"
end

function M.setup(opts)
  opts = opts or {}
  state.command = opts.command or find_command()
  state.current = ""
  state.rime_mode = ""
  state.running = false
  state.last_check = 0
  state.app_id = opts.app_id or detect_app_id()
  state.status_dir = (opts.status_dir or os.getenv("XDG_RUNTIME_DIR") or os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "")

  if not state.command then
    return false
  end

  local group = vim.api.nvim_create_augroup("input_method_status", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" }, {
    group = group,
    callback = function()
      M.refresh(true)
    end,
  })

  M.refresh(true)
  return true
end

return M
