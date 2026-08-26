describe("file search", function()
  it("keeps the default file-only source", function()
    local original_lazyvim = _G.LazyVim
    _G.LazyVim = {
      pick = function()
        return function() end
      end,
    }

    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/snacks.lua")
    _G.LazyVim = original_lazyvim

    assert.is_nil(spec.opts.picker.sources.files)
  end)
end)
