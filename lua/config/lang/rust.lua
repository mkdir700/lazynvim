local M = {}

function M.enabled()
  if vim.fn.executable("rustup") ~= 1 then
    return false
  end

  return true
end

return M
