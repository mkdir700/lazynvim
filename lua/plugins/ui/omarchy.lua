if vim.fn.hostname() ~= "omarchy" then
  return {}
end

local state_dir = vim.fn.expand("~/.local/state/omarchy/current")
local colors_file = state_dir .. "/theme/colors.toml"

local function read_colors()
  local colors = {}

  for _, line in ipairs(vim.fn.readfile(colors_file)) do
    local key, value = line:match('^([%w_]+)%s*=%s*"(#[%x]+)"')
    if key and value then
      colors[key] = value
    end
  end

  colors.bg = colors.background
  colors.dark_bg = colors.dark_background
  colors.darker_bg = colors.darker_background
  colors.lighter_bg = colors.lighter_background
  colors.fg = colors.foreground
  colors.dark_fg = colors.dark_foreground
  colors.light_fg = colors.light_foreground
  colors.bright_fg = colors.bright_foreground
  colors.cursor = colors.bright_foreground
  colors.selection_foreground = colors.selection_foreground or colors.bright_foreground
  colors.selection_background = colors.selection_background or colors.selection

  return colors
end

local function apply_theme()
  if vim.fn.filereadable(colors_file) == 0 then
    return
  end

  local ok, colors = pcall(read_colors)
  if not ok then
    return
  end

  require("aether").setup({ colors = colors })
  package.loaded["lualine.themes.aether"] = nil
  vim.cmd.colorscheme("aether")
end

return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    config = function()
      apply_theme()

      local watcher = vim.uv.new_fs_event()
      local timer = vim.uv.new_timer()
      if not watcher or not timer then
        return
      end

      watcher:start(state_dir, {}, function()
        timer:stop()
        timer:start(100, 0, vim.schedule_wrap(apply_theme))
      end)

      vim.api.nvim_create_autocmd("VimLeavePre", {
        once = true,
        callback = function()
          watcher:stop()
          watcher:close()
          timer:stop()
          timer:close()
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
