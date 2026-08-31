describe("lualine appearance", function()
  local status

  before_each(function()
    vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/everforest")
    vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/aether")
    status = {
      setup = function()
        return true
      end,
      component = function()
        return "中"
      end,
      is_chinese = function()
        return true
      end,
      available = function()
        return true
      end,
    }
    package.loaded["util.input_method_status"] = status
  end)

  after_each(function()
    package.loaded["util.input_method_status"] = nil
  end)

  it("adds a rounded input method segment without replacing LazyVim sections", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/ui/lualine.lua")
    local existing = {
      function()
        return "existing"
      end,
    }
    local opts = {
      options = {},
      sections = {
        lualine_x = existing,
      },
    }

    spec.opts(nil, opts)

    assert.are.equal(vim.fn.hostname() == "omarchy" and "aether" or "everforest", opts.options.theme)
    assert.are.same({ left = "", right = "" }, opts.options.section_separators)
    assert.are.same({ left = "", right = "" }, opts.options.component_separators)
    assert.are.equal(2, #opts.sections.lualine_x)
    assert.are.equal("中", opts.sections.lualine_x[1][1]())
    assert.are.equal("existing", opts.sections.lualine_x[2]())
  end)

  it("hides the input method segment in narrow windows", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/ui/lualine.lua")
    local opts = { options = {}, sections = { lualine_x = {} } }
    spec.opts(nil, opts)
    local input_method = opts.sections.lualine_x[1]

    vim.o.columns = 79
    assert.is_false(input_method.cond())
    vim.o.columns = 100
    assert.is_true(input_method.cond())
  end)

  it("uses the regular sections in neo-tree", function()
    local spec = dofile(vim.fn.getcwd() .. "/lua/plugins/ui/lualine.lua")
    local opts = {
      options = {},
      sections = { lualine_x = {} },
      extensions = { "neo-tree", "lazy", "fzf" },
    }

    spec.opts(nil, opts)

    assert.are.same({ "lazy", "fzf" }, opts.extensions)
  end)
end)
