describe("Rust use group shorthand", function()
  local function apply_insert_leave(line, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = filetype or "rust"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
    vim.api.nvim_win_set_cursor(0, { 1, #line - 1 })

    vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })

    return vim.api.nvim_get_current_line()
  end

  before_each(function()
    package.loaded["util.rust_use_group"] = nil

    local plugin = dofile(vim.fn.getcwd() .. "/lua/plugins/nvim-treesitter.lua")
    if plugin.init then
      plugin.init()
    end
  end)

  after_each(function()
    package.loaded["util.rust_use_group"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "RustUseGroupShorthand")
  end)

  it("groups a comma-appended import when insert mode ends", function()
    assert.equals(
      "pub(crate) use model::{JoinerStartMaterial, SpaceCommitToken};",
      apply_insert_leave("pub(crate) use model::JoinerStartMaterial, SpaceCommitToken;")
    )
  end)

  it("leaves ordinary comma expressions unchanged", function()
    assert.equals("let value = model::A, B;", apply_insert_leave("let value = model::A, B;"))
  end)

  it("leaves existing grouped imports unchanged", function()
    assert.equals("use model::{A, B};", apply_insert_leave("use model::{A, B};"))
  end)

  it("does not change non-Rust buffers", function()
    assert.equals("use model::A, B;", apply_insert_leave("use model::A, B;", "text"))
  end)
end)
