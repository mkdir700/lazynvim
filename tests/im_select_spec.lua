describe("input method switching", function()
  local original_system
  local original_im_select
  local original_defer_fn

  before_each(function()
    original_system = vim.system
    original_im_select = package.loaded["im_select"]
    original_defer_fn = vim.defer_fn
  end)

  after_each(function()
    vim.system = original_system
    vim.defer_fn = original_defer_fn
    package.loaded["im_select"] = original_im_select
    pcall(vim.api.nvim_del_augroup_by_name, "rime_insert_mode")
    pcall(vim.keymap.del, "i", "vswf")
  end)

  it("switches to Rime and removes vswf when typed in insert mode", function()
    local setup_options
    local switches = {}
    package.loaded["im_select"] = {
      setup = function(options)
        setup_options = options
      end,
    }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    assert.are.same({
      default_im_select = "com.apple.keylayout.ABC",
      default_command = "macism",
      set_default_events = {},
      set_previous_events = {},
    }, setup_options)

    assert.are.equal(0, vim.fn.exists("#rime_insert_mode#InsertEnter"))

    vim.api.nvim_set_current_line("")
    local keys = vim.api.nvim_replace_termcodes("ihellovswf<Esc>", true, false, true)
    vim.api.nvim_feedkeys(keys, "x", false)
    vim.wait(100, function()
      return #switches == 1
    end)

    assert.are.equal("hello", vim.api.nvim_get_current_line())
    assert.are.same({ { "macism", "com.apple.keylayout.ABC" } }, switches)
  end)

  it("uses Rime in Sidekick terminal input mode and ABC in terminal normal mode", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})
    vim.wait(100, function()
      return #switches == 1
    end)
    vim.api.nvim_exec_autocmds("TermLeave", {})
    vim.wait(100, function()
      return #switches == 2
    end)

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
      { "macism", "com.apple.keylayout.ABC" },
    }, switches)
  end)

  it("coalesces transient Sidekick mode changes into the final input method", function()
    local deferred = {}
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.defer_fn = function(callback)
      deferred[#deferred + 1] = callback
    end
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermLeave", {})
    vim.api.nvim_exec_autocmds("TermEnter", {})
    for _, callback in ipairs(deferred) do
      callback()
    end

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
    }, switches)
  end)

  it("finishes a newer input method request after an older request", function()
    local completions = {}
    local deferred = {}
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.defer_fn = function(callback)
      deferred[#deferred + 1] = callback
    end
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      completions[#completions + 1] = callback
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermLeave", {})
    assert.is_not_nil(deferred[#deferred])
    deferred[#deferred]()
    vim.api.nvim_exec_autocmds("TermEnter", {})
    assert.is_not_nil(deferred[#deferred])
    deferred[#deferred]()

    assert.are.same({ { "macism", "com.apple.keylayout.ABC" } }, switches)
    completions[1]({ code = 0 })
    vim.wait(100, function()
      return #switches == 2
    end)

    assert.are.same({
      { "macism", "com.apple.keylayout.ABC" },
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
    }, switches)
  end)

  it("leaves other terminals unchanged", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "snacks_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})
    vim.api.nvim_exec_autocmds("TermLeave", {})

    assert.are.same({}, switches)
  end)

  it("uses ABC after leaving Sidekick terminal input for a normal buffer", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})

    local normal_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(normal_buf)
    vim.wait(100, function()
      return #switches == 1
    end)

    assert.are.same({ { "macism", "com.apple.keylayout.ABC" } }, switches)
  end)

  it("uses ABC after leaving Sidekick for an already open normal window", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local sidekick_win = vim.api.nvim_get_current_win()
    vim.bo.filetype = "sidekick_terminal"
    vim.cmd.vnew()
    local normal_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(sidekick_win)

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()
    vim.api.nvim_exec_autocmds("TermEnter", {})

    vim.api.nvim_set_current_win(normal_win)
    vim.wait(100, function()
      return #switches == 1
    end)

    assert.are.same({ { "macism", "com.apple.keylayout.ABC" } }, switches)

    vim.api.nvim_win_close(normal_win, true)
  end)

  it("uses ABC as soon as a Sidekick terminal input window loses focus", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command, _, callback)
      switches[#switches + 1] = command
      if callback then
        callback({ code = 0 })
      end
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})
    vim.api.nvim_exec_autocmds("WinLeave", {})
    vim.wait(100, function()
      return #switches == 1
    end)

    assert.are.equal("com.apple.keylayout.ABC", switches[#switches][2])
  end)
end)
