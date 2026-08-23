describe("neo-tree appearance", function()
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
