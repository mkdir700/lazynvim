describe("input popup placement", function()
  it("opens above the symbol under the cursor", function()
    local original_lazyvim = _G.LazyVim
    _G.LazyVim = {
      pick = function()
        return function() end
      end,
    }
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/snacks.lua")
    _G.LazyVim = original_lazyvim
    local win = spec.opts.input and spec.opts.input.win

    assert.is_not_nil(win, "Snacks input window placement is missing")
    assert.are.equal("cursor", win.relative)
    assert.are.equal(-3, win.row)
    assert.are.equal(0, win.col)
  end)
end)
