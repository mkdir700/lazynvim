describe("Rust automatic check configuration", function()
  local original_rustaceanvim

  before_each(function()
    original_rustaceanvim = vim.g.rustaceanvim
    vim.g.rustaceanvim = nil
    package.loaded["config.lang.rust"] = nil
  end)

  after_each(function()
    vim.g.rustaceanvim = original_rustaceanvim
    package.loaded["config.lang.rust"] = nil
    pcall(vim.api.nvim_del_augroup_by_name, "rust_check_scheduler")
  end)

  it("lets Neovim schedule checks after saves become idle", function()
    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/lang/rust.lua")
    assert.are.equal(2, #specs)

    specs[2].init()

    local settings = vim.g.rustaceanvim.server.settings["rust-analyzer"]
    assert.is_false(settings.checkOnSave)
    assert.are.equal("", settings.check.extraEnv.RUSTC_WRAPPER)
  end)

  it("ensures rust-analyzer is installed by Mason", function()
    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/lang/rust.lua")
    local opts = { ensure_installed = { "codelldb" } }

    specs[1].opts(nil, opts)
    specs[1].opts(nil, opts)

    assert.are.same({ "codelldb", "rust-analyzer" }, opts.ensure_installed)
  end)
end)
