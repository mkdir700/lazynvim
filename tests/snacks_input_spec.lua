describe("input popup placement", function()
  it("opens above the symbol under the cursor", function()
    local original_lazyvim = _G.LazyVim
    _G.LazyVim = {
      pick = function()
        return function() end
      end,
    }
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/snacks.lua")
    _G.LazyVim = original_lazyvim
    local win = spec.opts.input and spec.opts.input.win

    assert.is_not_nil(win, "Snacks input window placement is missing")
    assert.are.equal("cursor", win.relative)
    assert.are.equal(-3, win.row)
    assert.are.equal(0, win.col)
  end)

  it("fills the gap with dots before the right-aligned jump label", function()
    local original_lazyvim = _G.LazyVim
    local original_flash = package.loaded.flash
    local jump_opts
    _G.LazyVim = {
      pick = function()
        return function() end
      end,
    }
    package.loaded.flash = {
      jump = function(opts)
        jump_opts = opts
      end,
    }

    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/snacks.lua")
    spec.opts.picker.actions.flash({})

    local line = " file.rs"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { line })
    local width = vim.api.nvim_win_get_width(0)
    local label = jump_opts.label.format({
      match = { win = 0, pos = { 1, 0 }, label = "a" },
      hl_group = "FlashRainbow1",
    })

    package.loaded.flash = original_flash
    _G.LazyVim = original_lazyvim

    assert.are.equal("right_align", jump_opts.label.style)
    assert.same({
      {
        string.rep("·", width - vim.fn.strdisplaywidth(line) - 1),
        "SnacksPickerFlashLeaderFlashRainbow1",
      },
      { "a", "FlashRainbow1" },
    }, label)
  end)
end)
