describe("LSP references picker", function()
  it("keeps gr in the picker even when there is only one result", function()
    local original_lazyvim = _G.LazyVim
    _G.LazyVim = {
      pick = function()
        return function() end
      end,
    }

    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/snacks.lua")
    _G.LazyVim = original_lazyvim

    assert.is_false(spec.opts.picker.sources.lsp_references.auto_confirm)
    assert.is_function(spec.opts.picker.actions.sidekick_send)
  end)
end)
