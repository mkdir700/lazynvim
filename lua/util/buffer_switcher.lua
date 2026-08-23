local M = {}

local function path_parts(path)
  local parent = vim.fn.fnamemodify(path, ":h")
  return vim.split(parent, "/", { plain = true, trimempty = true })
end

local function parent_suffix(path, depth)
  local parts = path_parts(path)
  local first = math.max(#parts - depth + 1, 1)
  return table.concat(vim.list_slice(parts, first), "/")
end

local function label(item, items)
  local path = item.path
  if path == "" then
    return "[No Name]"
  end

  local filename = vim.fn.fnamemodify(path, ":t")
  local depth = 1
  local max_depth = #path_parts(path)

  for _, other in ipairs(items) do
    if other ~= item and vim.fn.fnamemodify(other.path, ":t") == filename then
      max_depth = math.max(max_depth, #path_parts(other.path))
    end
  end

  while depth < max_depth do
    local suffix = parent_suffix(path, depth)
    local unique = true
    for _, other in ipairs(items) do
      if
        other ~= item
        and vim.fn.fnamemodify(other.path, ":t") == filename
        and parent_suffix(other.path, depth) == suffix
      then
        unique = false
        break
      end
    end
    if unique then
      break
    end
    depth = depth + 1
  end

  local parent = parent_suffix(path, depth)
  return parent == "" and filename or (filename .. "  " .. parent .. "/")
end

function M.build(items)
  table.sort(items, function(a, b)
    return a.lastused > b.lastused
  end)

  local specs = {}
  for index, item in ipairs(vim.list_slice(items, 1, 10)) do
    specs[#specs + 1] = {
      tostring(index - 1),
      function()
        vim.api.nvim_set_current_buf(item.buf)
      end,
      desc = label(item, items),
      icon = { cat = "file", name = item.path },
    }
  end
  return specs
end

function M.expand()
  local current = vim.api.nvim_get_current_buf()
  local items = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      local info = vim.fn.getbufinfo(buf)[1]
      items[#items + 1] = {
        buf = buf,
        path = vim.api.nvim_buf_get_name(buf),
        lastused = info and info.lastused or 0,
      }
    end
  end

  return M.build(items)
end

return M
