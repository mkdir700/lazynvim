-- lua/config/lang/dotnet.lua
local M = {}

-- 是否真的启用 dotnet 语言栈
function M.enabled()
  -- 1️⃣ 系统里必须有 dotnet
  if vim.fn.executable("dotnet") ~= 1 then
    return false
  end

  -- 2️⃣ 可选：环境变量总开关（强烈推荐）
  if vim.env.NVIM_ENABLE_DOTNET == "0" then
    return false
  end

  return true
end

return M
