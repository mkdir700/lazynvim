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
      elseif platform == "mac" then
        local function switch_input_method(input_method)
          vim.system({ "macism", input_method })
        end

        require("im_select").setup({
          default_im_select = "com.apple.keylayout.ABC",
          default_command = "macism",
          set_default_events = { "InsertLeave", "CmdlineLeave", "VimEnter" },
          set_previous_events = {},
        })

        local group = vim.api.nvim_create_augroup("rime_insert_mode", { clear = true })
        vim.keymap.set("i", "vswf", function()
          switch_input_method("im.rime.inputmethod.Squirrel.Hans")
        end, {
          desc = "Switch to Rime input method",
        })
        vim.api.nvim_create_autocmd("TermEnter", {
          group = group,
          callback = function(args)
            if vim.bo[args.buf].filetype == "sidekick_terminal" then
              switch_input_method("im.rime.inputmethod.Squirrel.Hans")
            end
          end,
        })
        vim.api.nvim_create_autocmd("TermLeave", {
          group = group,
          callback = function(args)
            if vim.bo[args.buf].filetype == "sidekick_terminal" then
              switch_input_method("com.apple.keylayout.ABC")
            end
          end,
        })
        vim.api.nvim_create_autocmd("WinLeave", {
          group = group,
          callback = function(args)
            if vim.bo[args.buf].filetype == "sidekick_terminal" then
              switch_input_method("com.apple.keylayout.ABC")
            end
          end,
        })
        vim.api.nvim_create_autocmd("BufEnter", {
          group = group,
          callback = function(args)
            vim.schedule(function()
              if
                vim.api.nvim_get_current_buf() == args.buf
                and vim.bo[args.buf].buftype ~= "terminal"
                and vim.api.nvim_get_mode().mode:sub(1, 1) == "n"
              then
                switch_input_method("com.apple.keylayout.ABC")
              end
            end)
          end,
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
