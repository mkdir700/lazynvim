local M = {}

local uv = vim.uv or vim.loop

M.WINDOW_SECONDS = 24 * 60 * 60

function M.created_at(stat)
  local birthtime = stat and stat.birthtime
  if not birthtime or not birthtime.sec or birthtime.sec <= 0 then
    return nil
  end
  return birthtime.sec + (birthtime.nsec or 0) / 1e9
end

function M.is_recent(stat, now)
  local created = M.created_at(stat)
  return created ~= nil and created >= now - M.WINDOW_SECONDS
end

function M.item(file, cwd, stat)
  local created = M.created_at(stat)
  if not created then
    return nil
  end
  return {
    text = file,
    file = file,
    cwd = cwd,
    created = created,
  }
end

function M.absolute_path(item)
  local file = item.file or item.text
  if item.cwd and vim.fn.isabsolutepath(file) == 0 then
    file = vim.fs.joinpath(item.cwd, file)
  end
  file = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
  return uv.fs_realpath(file) or file
end

function M.file_options(root)
  return {
    cwd = root,
    hidden = false,
    ignored = false,
    follow = false,
    exclude = {},
    args = {},
    ft = {},
    debug = {},
  }
end

function M.initial_seen(current_file)
  if current_file == "" then
    return {}
  end
  return { [M.absolute_path({ file = current_file })] = true }
end

function M.emit_unseen(seen, item, cb)
  local path = M.absolute_path(item)
  if seen[path] then
    return false
  end
  seen[path] = true
  cb(item)
  return true
end

function M.finder(opts, ctx)
  local recent_finder = require("snacks.picker.source.recent").files(opts, ctx)
  local root = opts.created_cwd or ctx:cwd()
  local file_opts = M.file_options(root)
  local file_ctx = ctx:clone(file_opts)
  local files_finder = require("snacks.picker.source.files").files(file_opts, file_ctx)
  local now = os.time()

  return function(cb)
    local seen = M.initial_seen(opts.current_file or "")
    recent_finder(function(item)
      M.emit_unseen(seen, item, cb)
    end)

    local created = {}
    files_finder(function(item)
      local path = M.absolute_path(item)
      if not seen[path] then
        local stat = uv.fs_stat(path)
        if M.is_recent(stat, now) then
          local created_item = M.item(item.file or item.text, item.cwd or root, stat)
          if created_item then
            created[#created + 1] = created_item
            seen[path] = true
          end
        end
      end
    end)

    table.sort(created, function(a, b)
      return a.created > b.created
    end)
    vim.iter(created):each(cb)
  end
end

function M.open_options(root, current_file)
  return {
    finder = M.finder,
    created_cwd = root,
    current_file = current_file,
  }
end

function M.open()
  local opts = M.open_options(LazyVim.root({ normalize = true }), vim.api.nvim_buf_get_name(0))
  Snacks.picker.recent(opts)
end

return M
