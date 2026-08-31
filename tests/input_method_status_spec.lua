describe("input method status", function()
  local original_system
  local original_lualine

  before_each(function()
    original_system = vim.system
    original_lualine = package.loaded["lualine"]
    package.loaded["util.input_method_status"] = nil
  end)

  after_each(function()
    vim.system = original_system
    package.loaded["lualine"] = original_lualine
    package.loaded["util.input_method_status"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "input_method_status")
  end)

  it("uses compact labels for English and Chinese input methods", function()
    local status = require("util.input_method_status")

    assert.are.equal("EN", status.label("com.apple.keylayout.ABC"))
    assert.are.equal("EN", status.label("keyboard-us"))
    assert.are.equal("EN", status.label("im.rime.inputmethod.Squirrel.Hans", "ascii"))
    assert.are.equal("中", status.label("im.rime.inputmethod.Squirrel.Hans", "nascii"))
    assert.are.equal("中", status.label("im.rime.inputmethod.Squirrel.Hans"))
    assert.are.equal("中", status.label("com.apple.inputmethod.SCIM.ITABC"))
    assert.are.equal("", status.label(""))
  end)

  it("queries asynchronously and reuses the recent result", function()
    local requests = {}
    local refreshes = 0
    package.loaded["lualine"] = {
      refresh = function()
        refreshes = refreshes + 1
      end,
    }
    vim.system = function(command, options, callback)
      requests[#requests + 1] = { command = command, options = options, callback = callback }
      return {}
    end

    local status = require("util.input_method_status")
    assert.is_true(status.setup({
      command = { "macism" },
      app_id = "test.app",
      status_dir = vim.fn.tempname(),
    }))
    assert.are.equal(1, #requests)
    assert.are.same({ "macism" }, requests[1].command)
    assert.is_true(requests[1].options.text)

    requests[1].callback({ code = 0, stdout = "im.rime.inputmethod.Squirrel.Hans\n" })
    vim.wait(100, function()
      return status.component() == "中"
    end)

    assert.are.equal("中", status.component())
    assert.are.equal(1, #requests)
    assert.are.equal(1, refreshes)
  end)

  it("reads the Rime state exported for the current application", function()
    local requests = {}
    local status_dir = vim.fn.tempname()
    vim.fn.mkdir(status_dir)
    vim.fn.writefile({ "ascii" }, status_dir .. "/rime-input-method-com.neovide.neovide.status")
    vim.system = function(command, options, callback)
      requests[#requests + 1] = { command = command, options = options, callback = callback }
      return {}
    end

    local status = require("util.input_method_status")
    assert.is_true(status.setup({
      command = { "macism" },
      app_id = "com.neovide.neovide",
      status_dir = status_dir,
    }))
    requests[1].callback({ code = 0, stdout = "im.rime.inputmethod.Squirrel.Hans\n" })
    vim.wait(100, function()
      return status.component() == "EN"
    end)
    assert.are.equal("EN", status.component())

    vim.fn.writefile({ "nascii" }, status_dir .. "/rime-input-method-com.neovide.neovide.status")
    status.refresh(true)
    requests[2].callback({ code = 0, stdout = "im.rime.inputmethod.Squirrel.Hans\n" })
    vim.wait(100, function()
      return status.component() == "中"
    end)
    assert.are.equal("中", status.component())

    vim.fn.delete(status_dir .. "/rime-input-method-com.neovide.neovide.status")
    vim.fn.delete(status_dir, "d")
  end)

  it("reads the Linux fcitx5-rime internal mode export", function()
    local requests = {}
    local status_dir = vim.fn.tempname()
    vim.fn.mkdir(status_dir)
    vim.fn.writefile({ "ascii" }, status_dir .. "/rime-input-method-fcitx5-rime.status")
    vim.system = function(command, options, callback)
      requests[#requests + 1] = { command = command, options = options, callback = callback }
      return {}
    end

    local status = require("util.input_method_status")
    assert.is_true(status.setup({
      command = { "fcitx5-remote", "-n" },
      status_dir = status_dir,
    }))
    requests[1].callback({ code = 0, stdout = "rime\n" })
    vim.wait(100, function()
      return status.component() == "EN"
    end)
    assert.are.equal("EN", status.component())

    vim.fn.delete(status_dir .. "/rime-input-method-fcitx5-rime.status")
    vim.fn.delete(status_dir, "d")
  end)
end)
