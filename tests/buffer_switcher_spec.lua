describe("buffer switcher", function()
  it("shows filenames first and sorts buffers by recent use", function()
    local ok, switcher = pcall(require, "util.buffer_switcher")
    assert.is_true(ok, "buffer switcher helper is missing")

    local specs = switcher.build({
      { buf = 11, path = "/project/crates/uc-application/src/space/assembly.rs", lastused = 20 },
      { buf = 12, path = "/project/crates/uc-application/src/space/query_space_members.rs", lastused = 40 },
    })

    assert.equals("0", specs[1][1])
    assert.equals("query_space_members.rs  space/", specs[1].desc)
    assert.equals("1", specs[2][1])
    assert.equals("assembly.rs  space/", specs[2].desc)
  end)

  it("adds only enough parent directories to distinguish duplicate filenames", function()
    local switcher = require("util.buffer_switcher")
    local specs = switcher.build({
      { buf = 21, path = "/project/crates/alpha/src/space/mod.rs", lastused = 20 },
      { buf = 22, path = "/project/crates/beta/src/space/mod.rs", lastused = 10 },
    })

    assert.equals("mod.rs  alpha/src/space/", specs[1].desc)
    assert.equals("mod.rs  beta/src/space/", specs[2].desc)
  end)

  it("provides the dynamic entries for the buffer menu", function()
    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/which-key.lua")
    local switcher = require("util.buffer_switcher")
    local mapping

    for _, item in ipairs(plugin.opts.spec) do
      if item[1] == "<leader>b" then
        mapping = item
        break
      end
    end

    assert.is_not_nil(mapping)
    assert.equals(switcher.expand, mapping.expand)
  end)
end)
