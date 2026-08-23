describe("smart paste", function()
  before_each(function()
    package.loaded["util.smart_paste"] = nil
    vim.cmd("enew!")
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "pub(crate) struct RecoverMissingSpaceMembershipStateUseCase {}",
    })
    local brace_column = assert(vim.api.nvim_get_current_line():find("{", 1, true)) - 1
    vim.api.nvim_win_set_cursor(0, { 1, brace_column })
  end)

  local function load_smart_paste()
    local loaded, module = pcall(require, "util.smart_paste")
    assert.is_true(loaded, "util.smart_paste must exist")
    return module
  end

  it("puts multiline text inside empty braces without entering insert mode", function()
    local smart_paste = load_smart_paste()
    vim.fn.setreg('"', {
      "      origin: SpaceMembershipStateOrigin,",
      "      repository: Arc<dyn WorkspaceConvergenceRepositoryPort>,",
    }, "V")

    local insert_events = 0
    local group = vim.api.nvim_create_augroup("smart_paste_spec", { clear = true })
    vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
      group = group,
      callback = function()
        insert_events = insert_events + 1
      end,
    })

    assert.is_true(smart_paste.into_empty_braces())
    assert.same({
      "pub(crate) struct RecoverMissingSpaceMembershipStateUseCase {",
      "  origin: SpaceMembershipStateOrigin,",
      "  repository: Arc<dyn WorkspaceConvergenceRepositoryPort>,",
      "}",
    }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.equals(0, insert_events)
    assert.equals("n", vim.api.nvim_get_mode().mode)

    vim.api.nvim_del_augroup_by_id(group)
  end)

  it("leaves ordinary paste situations untouched", function()
    local smart_paste = load_smart_paste()
    vim.fn.setreg('"', { "field: Type," }, "V")

    assert.is_false(smart_paste.into_empty_braces())
    assert.same({
      "pub(crate) struct RecoverMissingSpaceMembershipStateUseCase {}",
    }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)
end)
