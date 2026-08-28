describe("terminal selection", function()
  local original_snacks
  local buffers
  local terminals

  local function make_terminal(id)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "snacks_terminal"
    vim.b[buf].snacks_terminal = { id = id, cwd = vim.fn.getcwd() }

    local terminal = {
      buf = buf,
      opts = {},
      toggle_calls = 0,
      show_calls = 0,
      focus_calls = 0,
      hide_calls = 0,
      visible = true,
    }

    function terminal:buf_valid()
      return vim.api.nvim_buf_is_valid(self.buf)
    end

    function terminal:valid()
      return self.visible
    end

    function terminal:toggle()
      self.toggle_calls = self.toggle_calls + 1
      self.visible = not self.visible
    end

    function terminal:show()
      self.show_calls = self.show_calls + 1
      self.visible = true
      return self
    end

    function terminal:focus()
      self.focus_calls = self.focus_calls + 1
    end

    function terminal:hide()
      self.hide_calls = self.hide_calls + 1
      self.visible = false
      return self
    end

    buffers[#buffers + 1] = buf
    terminals[id] = terminal
    return terminal
  end

  before_each(function()
    original_snacks = _G.Snacks
    buffers = {}
    terminals = {}

    local terminal_api = {}
    function terminal_api.get(_, opts)
      return terminals[opts.count or 1]
    end
    function terminal_api.list()
      return vim.tbl_values(terminals)
    end
    setmetatable(terminal_api, {
      __call = function(_, _, opts)
        return make_terminal(opts.count or 1)
      end,
    })

    _G.Snacks = { terminal = terminal_api }
    package.loaded["util.terminal"] = nil
    require("util.terminal").setup()
  end)

  after_each(function()
    vim.api.nvim_create_augroup("snacks_term_position", { clear = true })
    vim.cmd("silent! enew")
    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
    package.loaded["util.terminal"] = nil
    _G.Snacks = original_snacks
  end)

  it("returns to the last used terminal when no count is given", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)
    local editor_buf = vim.api.nvim_create_buf(false, true)
    buffers[#buffers + 1] = editor_buf

    vim.api.nvim_set_current_buf(terminal_2.buf)
    vim.api.nvim_set_current_buf(editor_buf)
    terminal.toggle()

    assert.are.equal(0, terminal_1.toggle_calls)
    assert.are.equal(1, terminal_2.toggle_calls)
  end)

  it("honors an explicit terminal count", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    terminal.toggle({ count = 1 })

    assert.are.equal(1, terminal_1.focus_calls)
    assert.are.equal(1, terminal_2.hide_calls)
    assert.are.equal(0, terminal_1.toggle_calls)
    assert.are.equal(0, terminal_2.toggle_calls)
    assert.is_true(terminal_1.visible)
    assert.is_false(terminal_2.visible)
  end)

  it("hides the current terminal before creating another numbered terminal", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)

    terminal.toggle({ count = 2 })

    assert.are.equal(1, terminal_1.hide_calls)
    assert.is_false(terminal_1.visible)
    assert.is_true(terminals[2].visible)
  end)

  it("remembers the terminal selected by an explicit count", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    terminal.toggle({ count = 1 })
    terminal.toggle({ count = 2 })
    terminal.toggle()

    assert.are.equal(1, terminal_1.focus_calls)
    assert.are.equal(1, terminal_2.focus_calls)
    assert.are.equal(1, terminal_2.toggle_calls)
  end)

  it("renders numbered terminal tabs and highlights the current one", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    vim.api.nvim_set_current_buf(terminal_2.buf)
    local winbar = terminal.winbar()

    assert.matches("TERMINALS", winbar, 1, true)
    assert.matches("TerminalTabInactive# 1", winbar, 1, true)
    assert.matches("TerminalTabActive# 2", winbar, 1, true)
    assert.is_true(winbar:find(" 1 ", 1, true) < winbar:find(" 2 ", 1, true))
    assert.are.equal(0, terminal_1.focus_calls)
  end)

  it("selects a terminal by its displayed tab index", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    assert.is_true(terminal.select(2))

    assert.are.equal(0, terminal_1.focus_calls)
    assert.are.equal(1, terminal_2.focus_calls)
    assert.are.equal(1, terminal_1.hide_calls)
    assert.is_false(terminal_1.visible)
    assert.is_true(terminal_2.visible)
  end)

  it("cycles through terminals in numeric order", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    vim.api.nvim_set_current_buf(terminal_1.buf)
    assert.is_true(terminal.cycle(1))
    assert.are.equal(1, terminal_2.focus_calls)
    assert.is_false(terminal_1.visible)
    assert.is_true(terminal_2.visible)

    vim.api.nvim_set_current_buf(terminal_2.buf)
    assert.is_true(terminal.cycle(1))
    assert.are.equal(1, terminal_1.focus_calls)
    assert.is_true(terminal_1.visible)
    assert.is_false(terminal_2.visible)
  end)
end)
