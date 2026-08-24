describe("gp file preview", function()
  local original_cwd
  local original_snacks
  local temp_dir

  before_each(function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(win).relative == "" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
    vim.cmd("silent! only")
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

  it("falls back to definition preview when a variable matches a filename", function()
    local preview = require("config.goto_preview")
    vim.fn.writefile({}, temp_dir .. "/ordinary_variable")
    local source_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "print(ordinary_variable)" })
    vim.api.nvim_win_set_cursor(0, { 1, 8 })

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

  it("docks the file preview immediately right of its source window", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    local other_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "crates/uc-core/src/setup/status.rs:3" })
    local source_win = vim.api.nvim_get_current_win()
    vim.cmd("rightbelow vsplit")
    vim.api.nvim_win_set_buf(0, other_buf)
    local other_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(source_win)

    local floating = preview.goto_preview()
    local preview_buf = vim.api.nvim_win_get_buf(floating.win)
    local preview_keys = {}
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(preview_buf, "n")) do
      preview_keys[mapping.lhs] = true
    end
    for _, key in ipairs({ "H", "J", "K", "L" }) do
      assert.is_true(preview_keys["<C-W>" .. key])
    end

    preview.dock_file_preview(floating, "right")

    local wins = vim.tbl_filter(function(win)
      return vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(0))
    table.sort(wins, function(a, b)
      return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
    end)

    assert.are.same({ source_win, vim.api.nvim_get_current_win(), other_win }, wins)
    assert.are.equal(source_buf, vim.api.nvim_win_get_buf(wins[1]))
    assert.are.equal(other_buf, vim.api.nvim_win_get_buf(wins[3]))
    assert.are.same({ 3, 0 }, vim.api.nvim_win_get_cursor(wins[2]))
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(preview_buf, "n")) do
      assert.is_false(vim.tbl_contains({ "<C-W>H", "<C-W>J", "<C-W>K", "<C-W>L" }, mapping.lhs))
    end
  end)

  it("docks the file preview above only its source window", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    local other_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "crates/uc-core/src/setup/status.rs:3" })
    local source_win = vim.api.nvim_get_current_win()
    vim.cmd("rightbelow vsplit")
    vim.api.nvim_win_set_buf(0, other_buf)
    local other_win = vim.api.nvim_get_current_win()
    local other_height = vim.api.nvim_win_get_height(other_win)
    vim.api.nvim_set_current_win(source_win)

    local floating = preview.goto_preview()
    preview.dock_file_preview(floating, "above")
    local docked_win = vim.api.nvim_get_current_win()

    local docked_pos = vim.api.nvim_win_get_position(docked_win)
    local source_pos = vim.api.nvim_win_get_position(source_win)
    local other_pos = vim.api.nvim_win_get_position(other_win)
    assert.are.equal(docked_pos[2], source_pos[2])
    assert.is_true(docked_pos[1] < source_pos[1])
    assert.is_true(other_pos[2] > source_pos[2])
    assert.are.equal(other_height, vim.api.nvim_win_get_height(other_win))
    assert.are.same({ 3, 0 }, vim.api.nvim_win_get_cursor(docked_win))
  end)

  it("docks a definition preview relative to its source window", function()
    local preview = require("config.goto_preview")
    local source_buf = vim.api.nvim_create_buf(false, true)
    local definition_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(source_buf)
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "some_function()" })
    local source_win = vim.api.nvim_get_current_win()
    local original_goto_preview = package.loaded["goto-preview"]
    local floating
    package.loaded["goto-preview"] = {
      goto_preview_definition = function()
        local win = vim.api.nvim_open_win(definition_buf, true, {
          relative = "editor",
          row = 1,
          col = 1,
          width = 40,
          height = 10,
          style = "minimal",
        })
        floating = preview.attach_definition_preview(definition_buf, win)
        return floating
      end,
    }

    preview.goto_preview()
    preview.dock_file_preview(floating, "below")

    package.loaded["goto-preview"] = original_goto_preview
    local docked_win = vim.api.nvim_get_current_win()
    assert.are.equal(definition_buf, vim.api.nvim_win_get_buf(docked_win))
    assert.are.equal(vim.api.nvim_win_get_position(source_win)[2], vim.api.nvim_win_get_position(docked_win)[2])
    assert.is_true(vim.api.nvim_win_get_position(docked_win)[1] > vim.api.nvim_win_get_position(source_win)[1])
  end)
end)
