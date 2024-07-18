return {
  -- for local machine
  {
    "keaising/im-select.nvim",
    cond = function()
      -- 检查环境变量 SSH_TTY 是否存在
      return not os.getenv("SSH_TTY")
    end,
    config = function()
      require("im_select").setup({
        default_im_select = "keyboard-us",
        default_command = "fcitx5-remote",
      })
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
