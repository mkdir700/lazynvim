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
    }

    function terminal:buf_valid()
      return vim.api.nvim_buf_is_valid(self.buf)
    end

    function terminal:valid()
      return true
    end

    function terminal:toggle()
      self.toggle_calls = self.toggle_calls + 1
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

    assert.are.equal(1, terminal_1.toggle_calls)
    assert.are.equal(0, terminal_2.toggle_calls)
  end)

  it("remembers the terminal selected by an explicit count", function()
    local terminal = require("util.terminal")
    local terminal_1 = make_terminal(1)
    local terminal_2 = make_terminal(2)

    terminal.toggle({ count = 1 })
    terminal.toggle({ count = 2 })
    terminal.toggle()

    assert.are.equal(1, terminal_1.toggle_calls)
    assert.are.equal(2, terminal_2.toggle_calls)
  end)
end)
