describe("Rust angle bracket pairing", function()
  local autopair

  local function type_less_than_after(prefix, filetype)
    vim.cmd("enew!")
    vim.bo.filetype = filetype or "rust"
    vim.api.nvim_set_current_line(prefix)
    vim.api.nvim_feedkeys("A<", "xt", false)
    return vim.api.nvim_get_current_line()
  end

  before_each(function()
    vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/ultimate-autopair.nvim")
    autopair = require("ultimate-autopair")
    autopair.clear()

    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/editor/autopair.lua")
    autopair.setup(spec.opts)
  end)

  after_each(function()
    autopair.clear()
    vim.cmd("bwipeout!")
  end)

  it("pairs a generic type", function()
    assert.equals("Vec<>", type_less_than_after("Vec"))
  end)

  it("pairs a turbofish", function()
    assert.equals("foo::<>", type_less_than_after("foo::"))
  end)

  it("leaves a spaced comparison unchanged", function()
    assert.equals("a <", type_less_than_after("a "))
  end)

  it("skips the closing bracket after a type parameter", function()
    local command = table.concat({
      "require('lazy').load({ plugins = { 'ultimate-autopair.nvim' } })",
      "vim.cmd('enew')",
      "vim.bo.filetype = 'rust'",
      "vim.api.nvim_set_current_line('Vec<T>')",
      "vim.api.nvim_win_set_cursor(0, { 1, 4 })",
      "vim.api.nvim_feedkeys('a>', 'xt', false)",
      "io.stdout:write(vim.api.nvim_get_current_line() .. '\\n')",
      "vim.cmd('qa!')",
    }, "; ")
    local result = vim
      .system({
        "env",
        "-u",
        "NVIM",
        "nvim",
        "-u",
        "init.lua",
        "-i",
        "NONE",
        "-n",
        "--headless",
        "-c",
        "lua " .. command,
      }, { text = true })
      :wait(10000)

    assert.equals(0, result.code)
    assert.equals("Vec<T>\n", result.stdout)
  end)

  it("does not add the Rust rule to other file types", function()
    assert.equals("Vec<", type_less_than_after("Vec", "lua"))
  end)
end)
