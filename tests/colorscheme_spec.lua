describe("colorscheme", function()
  it("uses Everforest and dims inactive windows", function()
    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/ui/colorscheme.lua")

    assert.are.equal("everforest", specs[1].opts.colorscheme)
    assert.are.equal("sainnhe/everforest", specs[2][1])

    specs[2].init()
    assert.are.equal("medium", vim.g.everforest_background)
    assert.are.equal(1, vim.g.everforest_dim_inactive_windows)
  end)
end)
