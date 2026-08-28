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
local WINBAR = "%!v:lua.require'util.terminal'.winbar()"
local last_terminal_buf

local function terminal_id(term)
  if not (term.buf and vim.api.nvim_buf_is_valid(term.buf)) then
    return nil
  end
  local data = vim.b[term.buf].snacks_terminal
  return type(data) == "table" and tonumber(data.id) or nil
end

local function terminals()
  local items = vim.tbl_filter(function(term)
    return term:buf_valid() and terminal_id(term) ~= nil
  end, Snacks.terminal.list())
  table.sort(items, function(a, b)
    local a_id, b_id = terminal_id(a), terminal_id(b)
    return a_id == b_id and a.buf < b.buf or a_id < b_id
  end)
  return items
end

local function use_tabbar(term)
  term.opts.wo = term.opts.wo or {}
  term.opts.wo.winbar = WINBAR
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.wo[term.win].winbar = WINBAR
  end
end

local function redraw_tabbar()
  for _, term in ipairs(terminals()) do
    use_tabbar(term)
  end
  vim.cmd("redrawstatus")
end

local function remember_terminal(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_terminal" then
    last_terminal_buf = buf
  end
end

local function get_last_terminal()
  if not (last_terminal_buf and vim.api.nvim_buf_is_valid(last_terminal_buf)) then
    return nil
  end
  for _, term in ipairs(Snacks.terminal.list()) do
    if term.buf == last_terminal_buf and term:buf_valid() then
      return term
    end
  end
end

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

local function hide_other_terminals(selected)
  for _, term in ipairs(terminals()) do
    if term ~= selected and term:valid() then
      term:hide()
    end
  end
end

local function focus(term)
  remember_terminal(term.buf)
  use_tabbar(term)
  hide_other_terminals(term)
  if not term:valid() then
    term.opts.position = get_position(term.buf)
    term:show()
  end
  term:focus()
  redraw_tabbar()
end

-- 终端 winbar:数字与 `1<C-\`>` / `2<C-\`>` 使用相同的终端 id。
-- 点击区域的 minwid 保存排序后的序号,避免把 buffer id 暴露成 UI 标签。
function M.winbar()
  local current_win = vim.g.statusline_winid
  local current_buf = current_win and vim.api.nvim_win_is_valid(current_win)
      and vim.api.nvim_win_get_buf(current_win)
    or vim.api.nvim_get_current_buf()
  local parts = { "%#TerminalTabFill# TERMINALS " }
  for index, term in ipairs(terminals()) do
    local hl = term.buf == current_buf and "TerminalTabActive" or "TerminalTabInactive"
    parts[#parts + 1] = ("%%%d@v:lua.TerminalTabClick@%%#%s# %d %%T"):format(index, hl, terminal_id(term))
  end
  parts[#parts + 1] = "%#TerminalTabFill#%="
  return table.concat(parts)
end

function M.select(index)
  local term = terminals()[index]
  if not term then
    return false
  end
  focus(term)
  return true
end

function M.cycle(direction)
  local items = terminals()
  if #items < 2 then
    return false
  end
  local current = vim.api.nvim_get_current_buf()
  local index
  for i, term in ipairs(items) do
    if term.buf == current then
      index = i
      break
    end
  end
  if not index then
    for i, term in ipairs(items) do
      if term.buf == last_terminal_buf then
        index = i
        break
      end
    end
  end
  index = index or 1
  index = ((index - 1 + direction) % #items) + 1
  focus(items[index])
  return true
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
      remember_terminal(buf)
    end
  end
end

-- 打开/切换 cwd 终端,并应用/更新记忆的位置
function M.toggle(opts)
  opts = opts or {}
  local count = opts.count or (vim.v.count > 0 and vim.v.count or nil)
  local selecting = count ~= nil
  if count then
    opts.count = count
  end

  local term = count == nil and get_last_terminal() or nil
  term = term or Snacks.terminal.get(nil, vim.tbl_extend("force", { create = false }, opts))
  if term and term:buf_valid() then
    if selecting then
      focus(term)
    else
      remember_terminal(term.buf)
      use_tabbar(term)
      -- 当前隐藏、即将显示:把该 buffer 记住的位置写回再 show
      if not term:valid() then
        term.opts.position = get_position(term.buf)
      end
      term:toggle()
    end
  else
    if selecting then
      hide_other_terminals()
    end
    term = Snacks.terminal(nil, vim.tbl_extend("force", { win = { position = DEFAULT_POSITION } }, opts))
    remember_terminal(term.buf)
    use_tabbar(term)
  end
  redraw_tabbar()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("snacks_term_position", { clear = true })

  vim.api.nvim_set_hl(0, "TerminalTabActive", { default = true, link = "TabLineSel" })
  vim.api.nvim_set_hl(0, "TerminalTabInactive", { default = true, link = "TabLine" })
  vim.api.nvim_set_hl(0, "TerminalTabFill", { default = true, link = "WinBar" })

  _G.TerminalTabClick = function(index)
    require("util.terminal").select(index)
  end

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
      remember_terminal(args.buf)
      if vim.bo[args.buf].filetype == "snacks_terminal" then
        redraw_tabbar()
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      if args.buf == last_terminal_buf then
        last_terminal_buf = nil
      end
      vim.schedule(redraw_tabbar)
    end,
  })

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
