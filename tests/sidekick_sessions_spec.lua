describe("Sidekick sessions", function()
  it("reuses Sidekick while keeping the previous Codex session in tmux", function()
    local original_session = package.loaded["sidekick.cli.session"]
    local original_state = package.loaded["sidekick.cli.state"]
    local original_sessions = package.loaded["util.sidekick_sessions"]
    local created
    local attached
    local detached
    local events = {}

    package.loaded["sidekick.cli.session"] = {
      new = function(opts)
        events[#events + 1] = "new"
        created = opts
        return { id = opts.id }
      end,
    }
    package.loaded["sidekick.cli.state"] = {
      get = function(filter)
        assert.same({ attached = true, name = "codex" }, filter)
        return { { session = { id = "current-codex" } } }
      end,
      detach = function(state)
        events[#events + 1] = "detach"
        detached = state
      end,
      get_state = function(session)
        return { session = session }
      end,
      attach = function(state, opts)
        events[#events + 1] = "attach"
        attached = { state = state, opts = opts }
        return state
      end,
    }
    package.loaded["util.sidekick_sessions"] = nil

    local ok, sessions = pcall(require, "util.sidekick_sessions")

    assert.is_true(ok, "Sidekick session helper is missing")
    sessions.new_codex()
    assert.equals("codex", created.tool)
    assert.equals("tmux", created.backend)
    assert.matches("^sidekick%-codex%-", created.id)
    assert.equals("current-codex", detached.session.id)
    assert.same({ "detach", "new", "attach" }, events)
    assert.is_true(attached.opts.show)
    assert.is_true(attached.opts.focus)

    package.loaded["sidekick.cli.session"] = original_session
    package.loaded["sidekick.cli.state"] = original_state
    package.loaded["util.sidekick_sessions"] = original_sessions
  end)

  it("binds aC to start a new Codex session", function()
    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick.lua")
    local mapping

    for _, key in ipairs(plugin.keys) do
      if key[1] == "<leader>aC" then
        mapping = key
        break
      end
    end

    assert.is_not_nil(mapping)
  end)

  it("routes ac through the recoverable Codex toggle", function()
    local original_sessions = package.loaded["util.sidekick_sessions"]
    local called = false
    package.loaded["util.sidekick_sessions"] = {
      toggle_codex = function()
        called = true
      end,
    }

    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick.lua")
    for _, key in ipairs(plugin.keys) do
      if key[1] == "<leader>ac" then
        key[2]()
        break
      end
    end

    assert.is_true(called)
    package.loaded["util.sidekick_sessions"] = original_sessions
  end)

  it("uses Sidekick's lifecycle when toggling Codex", function()
    local original_cli = package.loaded["sidekick.cli"]
    local original_state = package.loaded["sidekick.cli.state"]
    local original_sessions = package.loaded["util.sidekick_sessions"]
    local toggle_opts

    package.loaded["sidekick.cli"] = {
      toggle = function(opts)
        toggle_opts = opts
      end,
    }
    package.loaded["sidekick.cli.state"] = {
      get = function()
        error("toggle_codex should not inspect Sidekick's internal state")
      end,
    }
    package.loaded["util.sidekick_sessions"] = nil

    require("util.sidekick_sessions").toggle_codex()

    assert.same({ name = "codex", focus = true }, toggle_opts)
    package.loaded["sidekick.cli"] = original_cli
    package.loaded["sidekick.cli.state"] = original_state
    package.loaded["util.sidekick_sessions"] = original_sessions
  end)

  it("binds ctrl-s to session selection only inside Sidekick", function()
    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick.lua")
    local mapping = plugin.opts.cli.win.keys.select_session

    assert.is_not_nil(mapping)
    assert.equals("<c-s>", mapping[1])
    assert.is_function(mapping[2])
    assert.same({ "n", "t" }, mapping.mode)

    for _, key in ipairs(plugin.keys) do
      assert.not_equals("<c-s>", key[1])
    end
  end)

  it("binds x in normal mode to close the selected CLI session", function()
    local original_state = package.loaded["sidekick.cli.state"]
    local original_ui = package.loaded["sidekick.cli.ui.select"]
    local original_sessions = package.loaded["util.sidekick_sessions"]
    local original_select = vim.ui.select
    local select_opts
    local confirm_items

    package.loaded["sidekick.cli.state"] = {
      get = function(filter)
        assert.is_nil(filter)
        return { { installed = true, tool = { name = "codex" } } }
      end,
    }
    package.loaded["sidekick.cli.ui.select"] = {
      format = function()
        return { { "codex" } }
      end,
    }
    vim.ui.select = function(items, opts)
      if opts.prompt:match("^End session") then
        confirm_items = items
      else
        select_opts = opts
      end
    end
    package.loaded["util.sidekick_sessions"] = nil

    require("util.sidekick_sessions").select()

    assert.is_function(select_opts.snacks.actions.close_session)
    assert.same({ "close_session", mode = "n" }, select_opts.snacks.win.input.keys.x)
    assert.equals("close_session", select_opts.snacks.win.list.keys.x)
    assert.is_nil(select_opts.snacks.win.input.keys["<C-x>"])
    assert.is_nil(select_opts.snacks.win.list.keys["<C-x>"])
    select_opts.snacks.actions.close_session({ close = function() end }, {
      item = { tool = { name = "codex" }, session = { mux_session = "codex-test" } },
    })
    assert.same({ "Yes", "No" }, confirm_items)

    vim.ui.select = original_select
    package.loaded["sidekick.cli.state"] = original_state
    package.loaded["sidekick.cli.ui.select"] = original_ui
    package.loaded["util.sidekick_sessions"] = original_sessions
  end)

  it("replaces the displayed session when selecting another one", function()
    local original_session = package.loaded["sidekick.cli.session"]
    local original_state = package.loaded["sidekick.cli.state"]
    local original_ui = package.loaded["sidekick.cli.ui.select"]
    local original_sessions = package.loaded["util.sidekick_sessions"]
    local original_select = vim.ui.select
    local select_opts
    local select_cb
    local events = {}
    local current = { session = { id = "current-codex" } }
    local proxy
    local selected = {
      external = true,
      tool = {
        clone = function(_, opts)
          return { name = "codex", cmd = opts.cmd }
        end,
      },
      session = {
        id = "previous-codex",
        mux_backend = "tmux",
        mux_session = "sidekick-codex-previous",
      },
    }

    package.loaded["sidekick.cli.session"] = {
      new = function(opts)
        proxy = opts
        return opts
      end,
    }
    package.loaded["sidekick.cli.ui.select"] = {
      format = function()
        return { { "codex" } }
      end,
    }
    package.loaded["sidekick.cli.state"] = {
      get = function(filter)
        if filter == nil then
          return { selected }
        end
        assert.same({ attached = true }, filter)
        return { current }
      end,
      detach = function(state)
        events[#events + 1] = "detach:" .. state.session.id
      end,
      attach = function(state, opts)
        events[#events + 1] = "attach:" .. state.session.id
        assert.is_true(opts.show)
        assert.is_true(opts.focus)
      end,
      get_state = function(session)
        return { session = session }
      end,
    }
    vim.ui.select = function(_, opts, cb)
      select_opts = opts
      select_cb = cb
    end
    package.loaded["util.sidekick_sessions"] = nil

    local sessions = require("util.sidekick_sessions")
    assert.is_function(sessions.select)
    sessions.select()
    assert.equals("sidekick_cli", select_opts.kind)
    select_cb(selected)

    assert.same({ "detach:current-codex", "attach:sidekick-session-view" }, events)
    assert.equals("terminal", proxy.backend)
    assert.same({ "tmux", "attach-session", "-t", "sidekick-codex-previous" }, proxy.tool.cmd)

    vim.ui.select = original_select
    package.loaded["sidekick.cli.session"] = original_session
    package.loaded["sidekick.cli.state"] = original_state
    package.loaded["sidekick.cli.ui.select"] = original_ui
    package.loaded["util.sidekick_sessions"] = original_sessions
  end)
end)
