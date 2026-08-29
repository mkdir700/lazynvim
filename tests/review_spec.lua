describe("review.nvim", function()
  it("loads on demand with its required dependencies and review commands", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/review.lua")

    assert.equals("georgeguimaraes/review.nvim", spec[1])
    assert.equals("v*", spec.version)
    assert.same({ "esmuellert/codediff.nvim", "MunifTanjim/nui.nvim" }, spec.dependencies)
    assert.same({ "Review" }, spec.cmd)
    assert.same({}, spec.opts)

    assert.same({ "<leader>gr", "<cmd>Review<cr>", desc = "Review changes" }, spec.keys[1])
    assert.same({ "<leader>gR", "<cmd>Review commits<cr>", desc = "Review commits" }, spec.keys[2])
  end)
end)
