local M = {}

local function replace_attached(state)
  if not state then
    return
  end

  local State = require("sidekick.cli.state")
  for _, attached in ipairs(State.get({ attached = true })) do
    if not state.session or not attached.session or attached.session.id ~= state.session.id then
      State.detach(attached)
    end
  end

  local session = state.session
  local backend = session and (session.mux_backend or session.backend)
  if state.external and backend == "tmux" and session.mux_session then
    local Session = require("sidekick.cli.session")
    session = Session.new({
      tool = state.tool:clone({ cmd = { "tmux", "attach-session", "-t", session.mux_session } }),
      backend = "terminal",
      id = "sidekick-session-view",
      mux_backend = "tmux",
      mux_session = session.mux_session,
      parent = session,
    })
    state = State.get_state(session)
  end

  return State.attach(state, { show = true, focus = true })
end

function M.select(filter)
  local State = require("sidekick.cli.state")
  local Ui = require("sidekick.cli.ui.select")
  local states = State.get(filter)

  vim.ui.select(states, {
    prompt = "Select CLI tool:",
    kind = "sidekick_cli",
    format_item = function(state)
      return table.concat(vim.tbl_map(function(part)
        return part[1]
      end, Ui.format(state)))
    end,
    snacks = {
      format = Ui.format,
      actions = {
        close_session = function(picker, item)
          local state = item and item.item
          if not (state and state.session) then
            return
          end

          picker:close()
          local name = state.session.mux_session or state.tool.name
          vim.ui.select({ "Yes", "No" }, { prompt = ("End session %s?"):format(name) }, function(_, idx)
            if idx == 1 then
              M.close(state)
            end
            vim.schedule(M.select)
          end)
        end,
      },
      win = {
        input = { keys = { x = { "close_session", mode = "n" } } },
        list = { keys = { x = "close_session" } },
      },
    },
  }, replace_attached)
end

function M.toggle_codex()
  return require("sidekick.cli").toggle({ name = "codex", focus = true })
end

function M.close(state)
  local session = state and state.session
  if not session then
    return false
  end

  local State = require("sidekick.cli.state")
  local mux_session = session.mux_session
  for _, attached in ipairs(State.get({ attached = true })) do
    if
      attached.session
      and (attached.session.id == session.id or (mux_session and attached.session.mux_session == mux_session))
    then
      State.detach(attached)
    end
  end

  if mux_session then
    local result = vim.system({ "tmux", "kill-session", "-t", mux_session }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr or ("Failed to end session %s"):format(mux_session), vim.log.levels.ERROR)
      return false
    end
    return true
  end

  if state.attached then
    State.detach(state)
    return true
  end
  return false
end

function M.new_codex()
  local Session = require("sidekick.cli.session")
  local State = require("sidekick.cli.state")
  local uv = vim.uv or vim.loop

  for _, state in ipairs(State.get({ attached = true, name = "codex" })) do
    State.detach(state)
  end

  local session = Session.new({
    tool = "codex",
    backend = "tmux",
    id = ("sidekick-codex-%d-%d"):format(vim.fn.getpid(), uv.hrtime()),
  })

  return State.attach(State.get_state(session), { show = true, focus = true })
end

return M
