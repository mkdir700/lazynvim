local M = {}

local function run(cmd)
  local result = vim.system(cmd, { text = true }):wait()
  return result.code, result.stdout or ""
end

function M.fallback(opts)
  opts = opts or {}
  local pid = (opts.buffer_name or ""):match("//(%d+):")
  if not pid then
    return
  end

  local execute = opts.run or run
  local code, command = execute({ "ps", "-p", pid, "-o", "command=" })
  if code ~= 0 then
    return
  end
  local session = command:match("%-s%s+([^%s]+)")
  if not session then
    return
  end

  code, command = execute({ "tmux", "list-panes", "-t", session, "-F", "#{pane_id}" })
  if code ~= 0 then
    return
  end
  local exists = opts.exists or function(path)
    return (vim.uv or vim.loop).fs_stat(path) ~= nil
  end
  for pane in command:gmatch("[^\r\n]+") do
    if exists(vim.fs.joinpath(opts.registry_dir, pane .. ".json")) then
      return pane
    end
  end
end

function M.active_pane(registry_dir)
  if vim.bo.filetype == "sidekick-reader" then
    return vim.b.sidekick_reader_pane_id
  end

  local current = vim.api.nvim_get_current_buf()
  local ok, states = pcall(require("sidekick.cli.state").get, { attached = true, name = "codex" })
  if ok then
    for _, state in ipairs(states) do
      if state.terminal and state.terminal.buf == current and state.session then
        local session = state.session.parent or state.session
        return session.tmux_pane_id or (session.pane_id and session:pane_id())
      end
    end
  end

  return M.fallback({
    buffer_name = vim.api.nvim_buf_get_name(current),
    registry_dir = registry_dir,
  })
end

function M.terminal_pane(terminal)
  local ok, states = pcall(require("sidekick.cli.state").get, { attached = true, name = "codex" })
  if not ok then
    return
  end
  for _, state in ipairs(states) do
    if state.terminal == terminal and state.session then
      local session = state.session.parent or state.session
      return session.tmux_pane_id or (session.pane_id and session:pane_id())
    end
  end
end

return M
