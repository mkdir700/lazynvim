-- 让 Snacks 终端记住上次的布局位置(bottom/top/left/right)。
--
-- 原理:Snacks 把终端窗口位置存在终端对象的 `opts.position` 里,toggle 隐藏后
-- 再 show 时按这个值重建。用 `C-w R` 等命令移动窗口只改变了实际布局,并不会
-- 同步回 `opts.position`,所以位置会"丢失"。这里在离开/关闭终端窗口时探测其
-- 真实位置并写回,下次打开就能复原。
--
-- 生命周期:位置记忆是「按 buffer + 纯内存」的——存在终端 buffer 的 buffer-local
-- 变量 `b:term_position` 里,每个 buffer 各记各的,buffer 销毁时自动回收,不落盘。

local M = {}

-- 新建终端时的默认位置(还没有任何记忆时使用)。
local DEFAULT_POSITION = "bottom"

-- 读取某个 buffer 记住的位置(buffer-local,纯内存)。
local function get_position(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local ok, p = pcall(function()
      return vim.b[buf].term_position
    end)
    if ok and p and p ~= "" then
      return p
    end
  end
  return DEFAULT_POSITION
end

-- 探测窗口当前的物理位置:float / top / bottom / left / right
local function detect(win)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return nil
  end
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative and cfg.relative ~= "" then
    return "float"
  end
  local pos = vim.api.nvim_win_get_position(win)
  local row, col = pos[1], pos[2]
  local width = vim.api.nvim_win_get_width(win)
  if width >= vim.o.columns - 1 then
    -- 占满宽度 => 水平分屏
    return row == 0 and "top" or "bottom"
  else
    -- 未占满宽度 => 垂直分屏
    return col == 0 and "left" or "right"
  end
end

-- 把窗口当前位置写回它所属 buffer 的 buffer-local 变量。
local function remember(win)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end
  local p = detect(win)
  -- 不记忆 float(C-w 移动不会产生 float,且 float 复原需要额外尺寸配置)
  if p and p ~= "float" then
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) then
      vim.b[buf].term_position = p
    end
  end
end

-- 打开/切换 cwd 终端,并应用/更新记忆的位置
function M.toggle(opts)
  opts = opts or {}
  local term = Snacks.terminal.get(nil, vim.tbl_extend("force", { create = false }, opts))
  if term and term:buf_valid() then
    -- 当前隐藏、即将显示:把该 buffer 记住的位置写回再 show
    if not term:valid() then
      term.opts.position = get_position(term.buf)
    end
    term:toggle()
  else
    Snacks.terminal(nil, vim.tbl_extend("force", { win = { position = DEFAULT_POSITION } }, opts))
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("snacks_term_position", { clear = true })

  -- 离开终端窗口时(包括 toggle 隐藏前)记录位置,此时窗口仍有效
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      if vim.bo.filetype == "snacks_terminal" then
        remember(vim.api.nvim_get_current_win())
      end
    end,
  })

  -- 关闭终端窗口时再兜底记录一次
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local win = tonumber(args.match)
      if win and vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "snacks_terminal" then
          remember(win)
        end
      end
    end,
  })
end

return M
