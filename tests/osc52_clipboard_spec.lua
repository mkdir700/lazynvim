describe("OSC 52 clipboard toggle", function()
  local original_clipboard
  local original_option
  local original_osc52
  local original_notify

  before_each(function()
    original_clipboard = vim.g.clipboard
    original_option = vim.opt.clipboard:get()
    original_osc52 = package.loaded["vim.ui.clipboard.osc52"]
    original_notify = vim.notify
    package.loaded["util.osc52_clipboard"] = nil
  end)

  after_each(function()
    vim.g.clipboard = original_clipboard
    vim.opt.clipboard = original_option
    package.loaded["vim.ui.clipboard.osc52"] = original_osc52
    package.loaded["util.osc52_clipboard"] = nil
    vim.notify = original_notify
    vim.cmd("unlet! g:loaded_clipboard_provider")
    vim.cmd("runtime autoload/provider/clipboard.vim")
  end)

  it("enables OSC 52 and restores the previous clipboard", function()
    local osc52_copied
    local original_copied
    local copy_plus = function(lines)
      osc52_copied = lines
    end
    local copy_star = function() end
    local paste_plus = function() end
    local paste_star = function() end
    package.loaded["vim.ui.clipboard.osc52"] = {
      copy = function(register)
        return register == "+" and copy_plus or copy_star
      end,
      paste = function(register)
        return register == "+" and paste_plus or paste_star
      end,
    }
    vim.g.clipboard = {
      name = "original",
      copy = {
        ["+"] = function(lines)
          original_copied = lines
        end,
        ["*"] = function() end,
      },
      paste = {
        ["+"] = function()
          return { "" }
        end,
        ["*"] = function()
          return { "" }
        end,
      },
    }
    vim.opt.clipboard = "unnamed"
    vim.notify = function() end

    local clipboard = require("util.osc52_clipboard")
    assert.is_true(clipboard.toggle())
    assert.equals("OSC 52", vim.g.clipboard.name)
    assert.equals(copy_plus, vim.g.clipboard.copy["+"])
    assert.equals(copy_star, vim.g.clipboard.copy["*"])
    assert.equals(paste_plus, vim.g.clipboard.paste["+"])
    assert.equals(paste_star, vim.g.clipboard.paste["*"])
    assert.same({ "unnamedplus" }, vim.opt.clipboard:get())
    vim.fn["provider#clipboard#Call"]("set", { { "remote" }, "v", "+" })
    assert.same({ "remote" }, osc52_copied)

    assert.is_false(clipboard.toggle())
    assert.equals("original", vim.g.clipboard.name)
    assert.same({ "unnamed" }, vim.opt.clipboard:get())
    vim.fn["provider#clipboard#Call"]("set", { { "local" }, "v", "+" })
    assert.same({ "local" }, original_copied)
  end)

  it("registers leader uy without the legacy OSC 52 plugin", function()
    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/editor/clipboard.lua")
    local mapping
    for _, key in ipairs(specs[1].keys()) do
      if key[1] == "<leader>uy" then
        mapping = key
      end
    end

    assert.equals(1, #specs)
    assert.is_not_nil(mapping)
    assert.equals("Toggle OSC 52 Clipboard", mapping.desc)
  end)
end)
