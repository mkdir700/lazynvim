local M = {}

function M.send(paths)
  local ok, picker = pcall(require, "sidekick.cli.picker")
  if not ok then
    vim.notify("Sidekick is not available", vim.log.levels.WARN)
    return false
  end

  local seen = {}
  local items = {}
  for _, path in ipairs(paths or {}) do
    if path and path ~= "" and not seen[path] then
      seen[path] = true
      items[#items + 1] = { name = path }
    end
  end

  if #items == 0 then
    vim.notify("No files selected", vim.log.levels.WARN)
    return false
  end

  picker._send_cb()(items)
  return true
end

return M
