local function getPlatform()
  if vim.fn.has("wsl") == 1 then
    return "wsl"
  end

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
      return not os.getenv("SSH_TTY")
    end,
    config = function()
      -- 判断当前平台是否为 linux
      local platform = getPlatform()
      if platform == "wsl" then
        require("im_select").setup({
          -- Keep Microsoft Pinyin selected and switch its internal mode instead.
          -- This works even when Windows has no separate US keyboard layout.
          default_im_select = "0",
          default_command = { "AIMSwitcher.exe", "--imm" },
          keep_quiet_on_no_binary = true,
        })
      elseif platform == "linux" then
        require("im_select").setup({
          -- Keep Fcitx on Rime. F13/F14 are consumed by the local Rime
          -- processor to select its internal English/Chinese mode.
          default_im_select = "rime",
          default_command = "fcitx5-remote",
          set_default_events = { "InsertLeave", "CmdlineLeave", "VimEnter", "BufEnter", "WinEnter" },
          set_previous_events = {},
        })

        local group = vim.api.nvim_create_augroup("rime_linux_mode", { clear = true })
        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "VimEnter", "BufEnter", "WinEnter" }, {
          group = group,
          callback = function()
            vim.system({ "wtype", "-k", "F13" }, { detach = true })
          end,
          desc = "Select Rime internal English mode",
        })
        vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
          group = group,
          callback = function()
            vim.system({ "wtype", "-k", "F14" }, { detach = true })
          end,
          desc = "Select Rime internal Chinese mode",
        })
      elseif platform == "mac" then
        local desired_input_method
        local running_input_method
        local request_id = 0

        local function apply_input_method()
          if running_input_method or not desired_input_method then
            return
          end

          local input_method = desired_input_method
          running_input_method = input_method
          vim.system({ "macism", input_method }, {}, function()
            vim.schedule(function()
              running_input_method = nil
              if desired_input_method ~= input_method then
                apply_input_method()
              end
            end)
          end)
        end

        local function switch_input_method(input_method)
          desired_input_method = input_method
          request_id = request_id + 1
          local current_request = request_id
          vim.defer_fn(function()
            if current_request == request_id then
              apply_input_method()
            end
          end, 20)
        end

        require("im_select").setup({
          default_im_select = "com.apple.keylayout.ABC",
          default_command = "macism",
          set_default_events = {},
          set_previous_events = {},
        })

        local group = vim.api.nvim_create_augroup("rime_insert_mode", { clear = true })
        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "VimEnter" }, {
          group = group,
          callback = function()
            switch_input_method("com.apple.keylayout.ABC")
          end,
        })
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
