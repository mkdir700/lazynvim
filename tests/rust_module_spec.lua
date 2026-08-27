describe("Rust module registration", function()
  local temp_dir
  local mod_path
  local original_lazyvim
  local original_neo_tree_events

  local function load_module()
    package.loaded["util.rust_module"] = nil
    local loaded, rust_module = pcall(require, "util.rust_module")
    assert.is_true(loaded, rust_module)
    return rust_module
  end

  local function create_file(path, lines)
    assert.equals(0, vim.fn.writefile(lines or {}, path))
  end

  before_each(function()
    original_lazyvim = _G.LazyVim
    original_neo_tree_events = package.loaded["neo-tree.events"]
    temp_dir = vim.fn.tempname()
    assert.equals(1, vim.fn.mkdir(temp_dir, "p"))
    mod_path = vim.fs.joinpath(temp_dir, "mod.rs")
  end)

  after_each(function()
    pcall(vim.api.nvim_del_augroup_by_name, "rust_module_registration")
    vim.cmd("silent! %bwipeout!")
    vim.fn.delete(temp_dir, "rf")
    _G.LazyVim = original_lazyvim
    package.loaded["neo-tree.events"] = original_neo_tree_events
    package.loaded["util.rust_module"] = nil
  end)

  it("adds a module declaration after a Rust file is created", function()
    create_file(mod_path, { "pub mod existing;" })
    local file_path = vim.fs.joinpath(temp_dir, "status.rs")
    create_file(file_path)

    assert.is_true(load_module().register(file_path))
    assert.same({ "pub mod existing;", "mod status;" }, vim.fn.readfile(mod_path))
  end)

  it("does not add a duplicate declaration", function()
    create_file(mod_path, { "pub(crate) mod status;" })
    local file_path = vim.fs.joinpath(temp_dir, "status.rs")
    create_file(file_path)

    assert.is_false(load_module().register(file_path))
    assert.same({ "pub(crate) mod status;" }, vim.fn.readfile(mod_path))
  end)

  it("ignores mod.rs and invalid Rust module names", function()
    create_file(mod_path, {})
    local invalid_path = vim.fs.joinpath(temp_dir, "bad-name.rs")
    create_file(invalid_path)

    assert.is_false(load_module().register(mod_path))
    assert.is_false(load_module().register(invalid_path))
    assert.same({}, vim.fn.readfile(mod_path))
  end)

  it("does nothing when the directory has no mod.rs", function()
    local file_path = vim.fs.joinpath(temp_dir, "standalone.rs")
    create_file(file_path)

    assert.is_false(load_module().register(file_path))
    assert.equals(0, vim.fn.filereadable(mod_path))
  end)

  it("uses a raw identifier for Rust keyword filenames", function()
    create_file(mod_path, {})
    local file_path = vim.fs.joinpath(temp_dir, "type.rs")
    create_file(file_path)

    assert.is_true(load_module().register(file_path))
    assert.same({ "mod r#type;" }, vim.fn.readfile(mod_path))
  end)

  it("keeps unsaved mod.rs edits in its loaded buffer", function()
    create_file(mod_path, { "mod existing;" })
    vim.cmd("edit " .. vim.fn.fnameescape(mod_path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "mod existing;", "// unsaved" })
    local file_path = vim.fs.joinpath(temp_dir, "status.rs")
    create_file(file_path)

    assert.is_true(load_module().register(file_path))
    assert.same({ "mod existing;", "// unsaved", "mod status;" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.same({ "mod existing;" }, vim.fn.readfile(mod_path))
    assert.is_true(vim.bo.modified)
  end)

  it("registers a new editor buffer only after its first successful write", function()
    create_file(mod_path, {})
    local rust_module = load_module()
    rust_module.setup()
    local file_path = vim.fs.joinpath(temp_dir, "from_editor.rs")

    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    assert.same({}, vim.fn.readfile(mod_path))
    vim.api.nvim_set_current_line("pub fn created() {}")
    vim.cmd("write")

    assert.same({ "mod from_editor;" }, vim.fn.readfile(mod_path))
    vim.api.nvim_set_current_line("pub fn updated() {}")
    vim.cmd("write")
    assert.same({ "mod from_editor;" }, vim.fn.readfile(mod_path))
  end)

  it("registers files after Neo-tree reports a completed creation", function()
    local subscribed
    _G.LazyVim = {
      on_load = function(plugin, callback)
        assert.equals("neo-tree.nvim", plugin)
        callback()
      end,
    }
    package.loaded["neo-tree.events"] = {
      FILE_ADDED = "file_added",
      subscribe = function(handler)
        subscribed = handler
      end,
    }
    create_file(mod_path, {})
    local file_path = vim.fs.joinpath(temp_dir, "from_tree.rs")
    create_file(file_path)

    load_module().setup()
    assert.equals("file_added", subscribed.event)
    subscribed.handler(file_path)

    assert.same({ "mod from_tree;" }, vim.fn.readfile(mod_path))
  end)
end)
