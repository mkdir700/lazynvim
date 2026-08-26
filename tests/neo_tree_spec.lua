describe("neo-tree appearance", function()
  it("sends the current or selected paths to Sidekick with leader af", function()
    local original_sender = package.loaded["util.sidekick_files"]
    local received
    package.loaded["util.sidekick_files"] = {
      send = function(paths)
        received = paths
      end,
    }

    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")
    local current = { path = "/tmp/current.lua", type = "file" }
    spec.opts.commands.sidekick_send({ tree = {
      get_node = function()
        return current
      end,
    } })
    assert.same({ "/tmp/current.lua" }, received)

    current = { path = "/tmp/current-dir", type = "directory" }
    spec.opts.commands.sidekick_send({ tree = {
      get_node = function()
        return current
      end,
    } })
    assert.same({ "/tmp/current-dir" }, received)

    spec.opts.commands.sidekick_send_visual(nil, {
      { path = "/tmp/a.lua", type = "file" },
      { path = "/tmp/folder", type = "directory" },
      { path = "/tmp/b.lua", type = "file" },
    })
    assert.same({ "/tmp/a.lua", "/tmp/folder", "/tmp/b.lua" }, received)
    assert.equals("sidekick_send", spec.opts.window.mappings["<leader>af"])

    package.loaded["util.sidekick_files"] = original_sender
  end)

  it("leaves the statusline to lualine", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")

    assert.is_true(spec.opts.source_selector.winbar)
    assert.is_false(spec.opts.source_selector.statusline)
  end)

  it("hides the floating window title", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")

    assert.equals("", spec.opts.window.popup.title)
  end)

  it("opens in a floating window by default", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")

    assert.equals("float", spec.opts.window.position)
  end)

  it("uses 90 percent of the available height", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")

    assert.equals("90%", spec.opts.window.popup.size.height)
  end)
end)
