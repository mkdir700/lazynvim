describe("Sidekick file sending", function()
  local original_picker
  local original_notify

  before_each(function()
    original_picker = package.loaded["sidekick.cli.picker"]
    original_notify = vim.notify
    package.loaded["util.sidekick_files"] = nil
  end)

  after_each(function()
    package.loaded["sidekick.cli.picker"] = original_picker
    package.loaded["util.sidekick_files"] = nil
    vim.notify = original_notify
  end)

  it("sends unique file paths as Sidekick locations", function()
    local received
    package.loaded["sidekick.cli.picker"] = {
      _send_cb = function()
        return function(items)
          received = items
        end
      end,
    }

    local sent = require("util.sidekick_files").send({ "/tmp/a.lua", "/tmp/a.lua", "/tmp/b.lua" })

    assert.is_true(sent)
    assert.same({
      { name = "/tmp/a.lua" },
      { name = "/tmp/b.lua" },
    }, received)
  end)

  it("warns instead of failing when Sidekick is unavailable", function()
    local warning
    package.loaded["sidekick.cli.picker"] = nil
    package.preload["sidekick.cli.picker"] = function()
      error("missing")
    end
    vim.notify = function(message)
      warning = message
    end

    local sent = require("util.sidekick_files").send({ "/tmp/a.lua" })
    package.preload["sidekick.cli.picker"] = nil

    assert.is_false(sent)
    assert.matches("Sidekick", warning)
  end)
end)
