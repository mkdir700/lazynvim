local M = {}

local uv = vim.uv or vim.loop

local raw_keywords = {
  ["abstract"] = true,
  ["as"] = true,
  ["async"] = true,
  ["await"] = true,
  ["become"] = true,
  ["box"] = true,
  ["break"] = true,
  ["const"] = true,
  ["continue"] = true,
  ["dyn"] = true,
  ["do"] = true,
  ["else"] = true,
  ["enum"] = true,
  ["extern"] = true,
  ["false"] = true,
  ["final"] = true,
  ["fn"] = true,
  ["for"] = true,
  ["gen"] = true,
  ["if"] = true,
  ["impl"] = true,
  ["in"] = true,
  ["let"] = true,
  ["loop"] = true,
  ["macro"] = true,
  ["match"] = true,
  ["mod"] = true,
  ["move"] = true,
  ["mut"] = true,
  ["override"] = true,
  ["priv"] = true,
  ["pub"] = true,
  ["ref"] = true,
  ["return"] = true,
  ["static"] = true,
  ["struct"] = true,
  ["trait"] = true,
  ["true"] = true,
  ["try"] = true,
  ["type"] = true,
  ["typeof"] = true,
  ["unsafe"] = true,
  ["unsized"] = true,
  ["use"] = true,
  ["where"] = true,
  ["while"] = true,
  ["virtual"] = true,
  ["yield"] = true,
}

local unusable_names = {
  crate = true,
  self = true,
  Self = true,
  super = true,
}

local function module_name(file_path)
  if vim.fn.fnamemodify(file_path, ":e") ~= "rs" then
    return nil
  end

  local name = vim.fn.fnamemodify(file_path, ":t:r")
  if name == "mod" or unusable_names[name] or not name:match("^[%a_][%w_]*$") then
    return nil
  end

  return raw_keywords[name] and ("r#" .. name) or name
end

local function has_declaration(lines, name)
  local escaped = vim.pesc(name)
  local patterns = {
    "^%s*mod%s+" .. escaped .. "%s*[;{]",
    "^%s*pub%s+mod%s+" .. escaped .. "%s*[;{]",
    "^%s*pub%s*%b()%s+mod%s+" .. escaped .. "%s*[;{]",
  }

  for _, line in ipairs(lines) do
    local code = line:gsub("//.*$", "")
    for _, pattern in ipairs(patterns) do
      if code:match(pattern) then
        return true
      end
    end
  end
  return false
end

local function loaded_buffer(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr >= 0 and vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
  return nil
end

local function append_declaration(mod_path, name)
  local declaration = "mod " .. name .. ";"
  local bufnr = loaded_buffer(mod_path)
  if bufnr then
    local was_modified = vim.bo[bufnr].modified
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if has_declaration(lines, name) then
      return false
    end

    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { declaration })
    if not was_modified then
      local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
        vim.cmd("silent noautocmd write")
      end)
      if not ok then
        vim.notify("Could not save " .. mod_path .. ": " .. err, vim.log.levels.ERROR)
      end
    end
    return true
  end

  local lines = vim.fn.readfile(mod_path)
  if has_declaration(lines, name) then
    return false
  end

  lines[#lines + 1] = declaration
  if vim.fn.writefile(lines, mod_path) ~= 0 then
    vim.notify("Could not update " .. mod_path, vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.register(file_path)
  local path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":p"))
  local name = module_name(path)
  local file_stat = name and uv.fs_stat(path)
  if not file_stat or file_stat.type ~= "file" then
    return false
  end

  local mod_path = vim.fs.joinpath(vim.fs.dirname(path), "mod.rs")
  local mod_stat = uv.fs_stat(mod_path)
  if not mod_stat or mod_stat.type ~= "file" then
    return false
  end

  return append_declaration(mod_path, name)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("rust_module_registration", { clear = true })
  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    pattern = "*.rs",
    callback = function(event)
      vim.b[event.buf].rust_module_new_file = true
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.rs",
    callback = function(event)
      if not vim.b[event.buf].rust_module_new_file then
        return
      end

      vim.b[event.buf].rust_module_new_file = false
      M.register(event.file)
    end,
  })

  if _G.LazyVim and LazyVim.on_load then
    LazyVim.on_load("neo-tree.nvim", function()
      local events = require("neo-tree.events")
      events.subscribe({
        event = events.FILE_ADDED,
        id = "rust_module_registration",
        handler = M.register,
      })
    end)
  end
end

return M
