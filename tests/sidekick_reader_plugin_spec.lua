describe("Sidekick Reader plugin source", function()
  it("prefers the local checkout while retaining the public repository", function()
    local sidekick = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick.lua")
    local reader

    for _, dependency in ipairs(sidekick.dependencies or {}) do
      if dependency[1] == "mkdir700/sidekick-reader.nvim" then
        reader = dependency
        break
      end
    end

    assert.is_not_nil(reader)
    assert.equals("/Users/mark/MyProjects/sidekick-reader.nvim", reader.dir)
  end)
end)
