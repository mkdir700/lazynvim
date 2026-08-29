describe("Sidekick Reader plugin source", function()
  local enable
  local reader_dir

  before_each(function()
    enable = vim.env.NVIM_ENABLE_SIDEKICK_READER
    reader_dir = vim.env.SIDEKICK_READER_DIR
  end)

  after_each(function()
    vim.env.NVIM_ENABLE_SIDEKICK_READER = enable
    vim.env.SIDEKICK_READER_DIR = reader_dir
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
end)
