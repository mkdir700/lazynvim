describe("LSP rename persistence", function()
  local temp_dir

  before_each(function()
    temp_dir = vim.fn.tempname()
    vim.fn.mkdir(temp_dir, "p")
    vim.fn.writefile({ "old_name" }, temp_dir .. "/renamed.lua")
    vim.fn.writefile({ "keep_on_disk" }, temp_dir .. "/unrelated.lua")
    package.loaded["util.lsp_rename"] = nil
  end)

  after_each(function()
    vim.cmd("silent! %bwipeout!")
    vim.fn.delete(temp_dir, "rf")
    package.loaded["util.lsp_rename"] = nil
  end)

  it("saves files changed by rename without saving unrelated buffers", function()
    local unrelated = vim.fn.bufadd(temp_dir .. "/unrelated.lua")
    vim.fn.bufload(unrelated)
    vim.api.nvim_buf_set_lines(unrelated, 0, -1, false, { "still_unsaved" })

    local renamed_path = temp_dir .. "/renamed.lua"
    local renamed_uri = vim.uri_from_fname(renamed_path)
    local ok, rename = pcall(require, "util.lsp_rename")
    assert.is_true(ok, rename)

    rename.apply_and_save({
      changes = {
        [renamed_uri] = {
          {
            range = {
              start = { line = 0, character = 0 },
              ["end"] = { line = 0, character = 8 },
            },
            newText = "new_name",
          },
        },
      },
    }, "utf-16")

    assert.are.same({ "new_name" }, vim.fn.readfile(renamed_path))
    assert.are.same({ "keep_on_disk" }, vim.fn.readfile(temp_dir .. "/unrelated.lua"))
    assert.is_true(vim.bo[unrelated].modified)
  end)

  it("applies annotated rename edits without confirmation", function()
    local renamed_path = temp_dir .. "/renamed.lua"
    local renamed_uri = vim.uri_from_fname(renamed_path)
    local rename = require("util.lsp_rename")
    local original_confirm = vim.fn.confirm
    local confirm_calls = 0

    vim.fn.confirm = function(...)
      confirm_calls = confirm_calls + 1
      return original_confirm(...)
    end

    local ok, err = pcall(rename.apply_and_save, {
      documentChanges = {
        {
          textDocument = { uri = renamed_uri, version = 0 },
          edits = {
            {
              range = {
                start = { line = 0, character = 0 },
                ["end"] = { line = 0, character = 8 },
              },
              newText = "new_name",
              annotationId = "rename",
            },
          },
        },
      },
      changeAnnotations = {
        rename = {
          label = "Rename symbol",
          needsConfirmation = true,
        },
      },
    }, "utf-16")

    vim.fn.confirm = original_confirm

    assert.is_true(ok, err)
    assert.equals(0, confirm_calls)
    assert.are.same({ "new_name" }, vim.fn.readfile(renamed_path))
  end)
end)
