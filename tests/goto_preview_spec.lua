describe("gp file preview", function()
  local original_cwd
  local original_snacks
  local temp_dir

  before_each(function()
    original_cwd = vim.fn.getcwd()
    original_snacks = _G.Snacks
    _G.Snacks = {
      win = function(opts)
        local win = vim.api.nvim_open_win(opts.buf, opts.enter, {
          relative = "editor",
          row = 1,
          col = 1,
          width = opts.width,
          height = opts.height,
          style = "minimal",
          border = opts.border,
          title = opts.title,
          title_pos = opts.title_pos,
        })
        return { win = win }
      end,
    }
    temp_dir = vim.fn.tempname()
    vim.fn.mkdir(temp_dir .. "/crates/uc-core/src/setup", "p")
    local file_lines = {}
    for line = 1, 60 do
      file_lines[line] = "line " .. line
    end
    vim.fn.writefile(file_lines, temp_dir .. "/crates/uc-core/src/setup/status.rs")
    vim.api.nvim_set_current_dir(temp_dir)
  end)

  after_each(function()
    vim.api.nvim_set_current_dir(original_cwd)
    vim.cmd("silent! only")
    vim.cmd("silent! %bwipeout!")
    vim.fn.delete(temp_dir, "rf")
    _G.Snacks = original_snacks
  end)

  it("resolves an existing file without replacing the source buffer", function()
    local loaded, preview = pcall(require, "config.goto_preview")
    assert.is_true(loaded, preview)

    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, {
      "  └ crates/uc-core/src/setup/status.rs (+0 -12)",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 8 })

    local target = preview.resolve_file_under_cursor()

    assert.are.equal(source_buf, vim.api.nvim_get_current_buf())
    assert.are.equal(vim.uv.fs_realpath(temp_dir .. "/crates/uc-core/src/setup/status.rs"), target.path)
    assert.are.same({ 1, 0 }, target.cursor)
  end)

  it("resolves the line number following an existing file", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, {
      "crates/uc-core/src/setup/status.rs:3",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 8 })

    local target = preview.resolve_file_under_cursor()

    assert.are.equal(source_buf, vim.api.nvim_get_current_buf())
    assert.are.same({ 3, 0 }, target.cursor)
  end)

  it("resolves a file when the cursor is on its line number", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    local source_line = "// │ crates/uc-core/src/setup/status.rs:50"
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { source_line })
    local line_number_col = assert(source_line:find("50", 1, true)) - 1

    for digit_offset = 0, 1 do
      vim.api.nvim_win_set_cursor(0, { 1, line_number_col + digit_offset })
      local target = preview.resolve_file_under_cursor()

      assert.is_not_nil(target)
      assert.are.equal(vim.uv.fs_realpath(temp_dir .. "/crates/uc-core/src/setup/status.rs"), target.path)
      assert.are.same({ 50, 0 }, target.cursor)
    end
  end)

  it("falls back to definition preview when the cursor is not on a file", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "some_function()" })
    vim.api.nvim_win_set_cursor(0, { 1, 2 })

    local definition_called = false
    local original_goto_preview = package.loaded["goto-preview"]
    package.loaded["goto-preview"] = {
      goto_preview_definition = function()
        definition_called = true
      end,
    }

    preview.goto_preview()

    package.loaded["goto-preview"] = original_goto_preview
    assert.is_true(definition_called)
    assert.are.equal(source_buf, vim.api.nvim_get_current_buf())
  end)

  it("opens an existing file in a floating preview at the resolved line", function()
    local preview = require("config.goto_preview")
    local source_win = vim.api.nvim_get_current_win()
    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, {
      "crates/uc-core/src/setup/status.rs:3",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 8 })

    preview.goto_preview()

    local preview_win = vim.api.nvim_get_current_win()
    assert.are_not.equal(source_win, preview_win)
    assert.are.equal(source_buf, vim.api.nvim_win_get_buf(source_win))
    assert.are_not.equal("", vim.api.nvim_win_get_config(preview_win).relative)
    assert.are.equal(
      vim.uv.fs_realpath(temp_dir .. "/crates/uc-core/src/setup/status.rs"),
      vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(preview_win))
    )
    assert.are.same({ 3, 0 }, vim.api.nvim_win_get_cursor(preview_win))
  end)
end)
