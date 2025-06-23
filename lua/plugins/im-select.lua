local function getPlatform()
  local uname = vim.loop.os_uname()
  if uname.sysname == "Linux" then
    return "linux"
  elseif uname.sysname == "Darwin" then
    return "mac"
  elseif uname.sysname == "Windows_NT" then
    return "windows"
  else
    -- 抛出错误
    error("Unsupported system")
  end
end

return {
  -- for local machine
  {
    "keaising/im-select.nvim",
    cond = function()
      -- 检查环境变量 SSH_TTY 是否存在
      return not os.getenv("SSH_TTY") and not os.getenv("WSL_DISTRO_NAME")
    end,
    config = function()
      -- 判断当前平台是否为 linux
      local platform = getPlatform()
      if platform == "linux" then
        require("im_select").setup({
          default_im_select = "keyboard-us",
          default_command = "fcitx5-remote",
        })
      -- 判断当前平台是否为 macOS
      elseif platform == "mac" then
        require("im_select").setup({
          default_im_select = "com.apple.keylayout.ABC",
          default_command = "im-select",
        })
      end
    end,
  },
  -- for ssh
  {
    "mkdir700/im-select-remote.nvim",
    cond = function()
      -- 检查环境变量 SSH_TTY 是否存在
      return os.getenv("SSH_TTY")
    end,
    config = function()
      require("im-select-remote").setup({
        config = {
          socket = {
            command = "im-select -",
          },
        },
      })
    end,
  },
}
