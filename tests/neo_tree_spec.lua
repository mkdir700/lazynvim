describe("neo-tree appearance", function()
  it("leaves the statusline to lualine", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/neo-tree.lua")

    assert.is_true(spec.opts.source_selector.winbar)
    assert.is_false(spec.opts.source_selector.statusline)
  end)
end)
