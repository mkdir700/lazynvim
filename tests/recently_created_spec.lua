describe("recently created files", function()
  local recent

  before_each(function()
    package.loaded["util.recently_created"] = nil
    recent = require("util.recently_created")
  end)

  it("uses creation time instead of modification time", function()
    local stat = {
      birthtime = { sec = 100, nsec = 25 },
      mtime = { sec = 900, nsec = 75 },
    }

    assert.is_near(100.000000025, recent.created_at(stat), 0.000000001)
  end)

  it("ignores files whose creation time is unavailable", function()
    assert.is_nil(recent.created_at({ mtime = { sec = 900, nsec = 75 } }))
    assert.is_nil(recent.created_at({ birthtime = { sec = 0, nsec = 0 } }))
  end)

  it("only includes files created inside the recent window", function()
    local now = 200000
    local just_created = { birthtime = { sec = now - 60, nsec = 0 } }
    local old_but_modified = {
      birthtime = { sec = now - recent.WINDOW_SECONDS - 1, nsec = 0 },
      mtime = { sec = now, nsec = 0 },
    }

    assert.is_true(recent.is_recent(just_created, now))
    assert.is_false(recent.is_recent(old_but_modified, now))
  end)

  it("builds a sortable picker item", function()
    local item = recent.item("lua/config/options.lua", "/tmp/project", {
      birthtime = { sec = 123, nsec = 456 },
    })

    assert.same({
      text = "lua/config/options.lua",
      file = "lua/config/options.lua",
      cwd = "/tmp/project",
      created = 123.000000456,
    }, item)
  end)

  it("provides complete options to the project file search", function()
    assert.same({
      cwd = "/tmp/project",
      hidden = false,
      ignored = false,
      follow = false,
      exclude = {},
      args = {},
      ft = {},
      debug = {},
    }, recent.file_options("/tmp/project"))
  end)

  it("resolves project-relative file paths", function()
    assert.equals(
      "/tmp/project/lua/config/options.lua",
      recent.absolute_path({ file = "lua/config/options.lua", cwd = "/tmp/project" })
    )
  end)

  it("treats a symbolic directory path as the same real location", function()
    local real_tmp = (vim.uv or vim.loop).fs_realpath("/tmp")
    assert.equals(real_tmp, recent.absolute_path({ file = "/tmp" }))
  end)

  it("keeps the current file out of the merged results", function()
    assert.same({
      ["/tmp/project/current.lua"] = true,
    }, recent.initial_seen("/tmp/project/current.lua"))
    assert.same({}, recent.initial_seen(""))
  end)

  it("captures the current file before the search starts", function()
    local opts = recent.open_options("/tmp/project", "/tmp/project/current.lua")

    assert.equals(recent.finder, opts.finder)
    assert.equals("/tmp/project", opts.created_cwd)
    assert.equals("/tmp/project/current.lua", opts.current_file)
  end)

  it("does not emit an item that is already excluded or merged", function()
    local seen = recent.initial_seen("/tmp/project/current.lua")
    local emitted = {}

    assert.is_false(recent.emit_unseen(seen, { file = "/tmp/project/current.lua" }, function(item)
      emitted[#emitted + 1] = item
    end))
    assert.is_true(recent.emit_unseen(seen, { file = "/tmp/project/other.lua" }, function(item)
      emitted[#emitted + 1] = item
    end))
    assert.equals(1, #emitted)
    assert.equals("/tmp/project/other.lua", emitted[1].file)
  end)
end)
