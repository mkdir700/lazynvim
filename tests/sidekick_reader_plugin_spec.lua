describe("Sidekick Reader plugin source", function()
  local enable
  local reader_dir
  local no_proxy
  local lower_no_proxy

  before_each(function()
    enable = vim.env.NVIM_ENABLE_SIDEKICK_READER
    reader_dir = vim.env.SIDEKICK_READER_DIR
    no_proxy = vim.env.NO_PROXY
    lower_no_proxy = vim.env.no_proxy
  end)

  after_each(function()
    vim.env.NVIM_ENABLE_SIDEKICK_READER = enable
    vim.env.SIDEKICK_READER_DIR = reader_dir
    vim.env.NO_PROXY = no_proxy
    vim.env.no_proxy = lower_no_proxy
  end)

  it("does not load by default", function()
    vim.env.NVIM_ENABLE_SIDEKICK_READER = nil

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick-reader.lua")

    assert.same({}, specs)
  end)

  it("loads only when explicitly enabled", function()
    vim.env.NVIM_ENABLE_SIDEKICK_READER = "1"

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick-reader.lua")

    assert.equals("mkdir700/sidekick-reader.nvim", specs[1][1])
    assert.equals("folke/sidekick.nvim", specs[2][1])
  end)

  it("uses an optional local checkout behind its own plugin spec", function()
    vim.env.NVIM_ENABLE_SIDEKICK_READER = "1"
    vim.env.SIDEKICK_READER_DIR = "/tmp/sidekick-reader.nvim"

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick-reader.lua")

    assert.equals("mkdir700/sidekick-reader.nvim", specs[1][1])
    assert.equals("/tmp/sidekick-reader.nvim", specs[1].dir)
    assert.equals("stacked", specs[1].opts.layout)
    assert.equals(0.8, specs[1].opts.viewer_ratio)
    assert.equals("folke/sidekick.nvim", specs[2][1])
    assert.same({ "mkdir700/sidekick-reader.nvim" }, specs[2].dependencies)
  end)

  it("bypasses proxies when Codex connects to its local app server", function()
    vim.env.NO_PROXY = "example.com"
    vim.env.no_proxy = nil

    local specs = dofile(vim.fn.getcwd() .. "/lua/plugins/ai/sidekick-reader.lua")
    local opts = { cli = { win = { keys = {} }, tools = {} } }
    specs[2].opts(nil, opts)

    assert.equals("example.com,127.0.0.1,localhost", opts.cli.tools.codex.env.NO_PROXY)
    assert.equals("127.0.0.1,localhost", opts.cli.tools.codex.env.no_proxy)
  end)
end)
