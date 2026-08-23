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
    assert.are.equal(1, #specs)

    specs[1].init()

    local settings = vim.g.rustaceanvim.server.settings["rust-analyzer"]
    assert.is_false(settings.checkOnSave)
    assert.are.equal("", settings.check.extraEnv.RUSTC_WRAPPER)
  end)
end)
