describe("annotated declaration selection", function()
  local function range_for(filetype, lines, cursor)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = filetype
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, cursor)
    vim.treesitter.start(buf)
    vim.treesitter.get_parser(buf):parse()
    return require("util.annotated_declaration").range(buf)
  end

  it("includes contiguous Rust attributes before an enum", function()
    assert.same(
      { 0, 0, 4, 1 },
      range_for("rust", {
        "#[derive(Debug)]",
        "#[error(\"problem\")]",
        "pub enum Problem {",
        "  Locked,",
        "}",
      }, { 3, 4 })
    )
  end)

  it("keeps Python decorators with their class definition", function()
    assert.same(
      { 0, 0, 3, 8 },
      range_for("python", {
        "@dataclass",
        "@frozen",
        "class Problem:",
        "    pass",
      }, { 3, 7 })
    )
  end)

  it("registers aC as the annotated declaration text object", function()
    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/nvim-treesitter.lua")
    local mapping

    for _, key in ipairs(plugin.keys or {}) do
      if key[1] == "aC" then
        mapping = key
        break
      end
    end

    assert.is_not_nil(mapping)
    assert.same({ "x", "o" }, mapping.mode)
  end)

  it("selects a Rust definition from its first attribute through its end", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "rust"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "#[derive(Debug)]",
      "pub enum Problem {",
      "  Locked,",
      "}",
    })
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
    vim.treesitter.start(buf)
    vim.treesitter.get_parser(buf):parse()

    require("util.annotated_declaration").select()

    assert.equals("v", vim.api.nvim_get_mode().mode)
    assert.same({ 4, 0 }, vim.api.nvim_win_get_cursor(0))
    vim.cmd("normal! <esc>")
    assert.same({ 0, 1, 1, 0 }, vim.fn.getpos("'<"))
    assert.same({ 0, 4, 1, 0 }, vim.fn.getpos("'>"))
  end)

  it("selects Python decorators with their class definition", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "python"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "@dataclass",
      "class Problem:",
      "    pass",
    })
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, { 2, 7 })
    vim.treesitter.start(buf)
    vim.treesitter.get_parser(buf):parse()

    require("util.annotated_declaration").select()

    vim.cmd("normal! <esc>")
    assert.same({ 0, 1, 1, 0 }, vim.fn.getpos("'<"))
    assert.same({ 0, 3, 8, 0 }, vim.fn.getpos("'>"))
  end)
end)
