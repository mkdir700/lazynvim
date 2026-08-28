describe("ty LSP configuration", function()
  it("enables file-watch registration for external file changes", function()
    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/lang/python.lua")
    local ty

    for _, spec in ipairs(specs) do
      if spec[1] == "neovim/nvim-lspconfig" then
        ty = spec.opts.servers.ty
        break
      end
    end

    assert.is_not_nil(ty)
    assert.is_false(ty.mason)
    assert.is_true(ty.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration)
  end)
end)
