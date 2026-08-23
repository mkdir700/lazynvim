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
end)
