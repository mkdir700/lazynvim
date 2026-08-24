describe("input method switching", function()
  local original_system
  local original_im_select

  before_each(function()
    original_system = vim.system
    original_im_select = package.loaded["im_select"]
  end)

  after_each(function()
    vim.system = original_system
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
    vim.system = function(command)
      switches[#switches + 1] = command
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    assert.are.same({
      default_im_select = "com.apple.keylayout.ABC",
      default_command = "macism",
      set_default_events = { "InsertLeave", "CmdlineLeave", "VimEnter" },
      set_previous_events = {},
    }, setup_options)

    assert.are.equal(0, vim.fn.exists("#rime_insert_mode#InsertEnter"))

    vim.api.nvim_set_current_line("")
    local keys = vim.api.nvim_replace_termcodes("ihellovswf<Esc>", true, false, true)
    vim.api.nvim_feedkeys(keys, "x", false)

    assert.are.equal("hello", vim.api.nvim_get_current_line())
    assert.are.same({ { "macism", "im.rime.inputmethod.Squirrel.Hans" } }, switches)
  end)

  it("uses Rime in Sidekick terminal input mode and ABC in terminal normal mode", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command)
      switches[#switches + 1] = command
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})
    vim.api.nvim_exec_autocmds("TermLeave", {})

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
      { "macism", "com.apple.keylayout.ABC" },
    }, switches)
  end)

  it("leaves other terminals unchanged", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command)
      switches[#switches + 1] = command
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
    vim.system = function(command)
      switches[#switches + 1] = command
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})

    local normal_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(normal_buf)
    vim.wait(100, function()
      return #switches == 2
    end)

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
      { "macism", "com.apple.keylayout.ABC" },
    }, switches)
  end)

  it("uses ABC after leaving Sidekick for an already open normal window", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command)
      switches[#switches + 1] = command
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
      return #switches == 2
    end)

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
      { "macism", "com.apple.keylayout.ABC" },
    }, switches)

    vim.api.nvim_win_close(normal_win, true)
  end)

  it("uses ABC as soon as a Sidekick terminal input window loses focus", function()
    local switches = {}
    package.loaded["im_select"] = { setup = function() end }
    vim.system = function(command)
      switches[#switches + 1] = command
      return {}
    end

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/im-select.lua")
    specs[1].config()

    vim.bo.filetype = "sidekick_terminal"
    vim.api.nvim_exec_autocmds("TermEnter", {})
    vim.api.nvim_exec_autocmds("WinLeave", {})

    assert.are.same({
      { "macism", "im.rime.inputmethod.Squirrel.Hans" },
      { "macism", "com.apple.keylayout.ABC" },
    }, switches)
  end)
end)
