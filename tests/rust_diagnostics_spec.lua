describe("Rust diagnostics after an external reload", function()
  local original_get_clients
  local bufnr
  local diagnostic_namespace

  before_each(function()
    original_get_clients = vim.lsp.get_clients
    package.loaded["config.lang.rust"] = nil
    pcall(vim.api.nvim_del_user_command, "RustLsp")

    bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = "rust"
    diagnostic_namespace = vim.lsp.diagnostic.get_namespace(99123)
    vim.diagnostic.set(diagnostic_namespace, bufnr, {
      {
        lnum = 0,
        col = 0,
        message = "stale compiler error",
        severity = vim.diagnostic.severity.ERROR,
        source = "rustc",
      },
    })
  end)

  after_each(function()
    pcall(vim.api.nvim_del_augroup_by_name, "rust_diagnostics_external_reload")
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    vim.lsp.get_clients = original_get_clients
    package.loaded["config.lang.rust"] = nil
    pcall(vim.api.nvim_del_user_command, "RustLsp")
  end)

  it("clears and reruns the compiler check for the reloaded Rust buffer", function()
    local commands = {}
    local callback_buffers = {}
    vim.lsp.get_clients = function(opts)
      assert.are.equal(bufnr, opts.bufnr)
      assert.are.equal("rust-analyzer", opts.name)
      return { { id = 99123 } }
    end
    vim.api.nvim_create_user_command("RustLsp", function(opts)
      assert.are.equal("flyCheck", opts.fargs[1])
      commands[#commands + 1] = opts.fargs[2]
      callback_buffers[#callback_buffers + 1] = vim.api.nvim_get_current_buf()
    end, { nargs = "+" })

    require("config.lang.rust").setup_diagnostic_reload()
    vim.api.nvim_exec_autocmds("FileChangedShellPost", { buffer = bufnr, modeline = false })

    assert.are.same({ "clear", "run" }, commands)
    assert.are.same({ bufnr, bufnr }, callback_buffers)
    assert.are.same({}, vim.diagnostic.get(bufnr, { namespace = diagnostic_namespace }))
  end)
end)
