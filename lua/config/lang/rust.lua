local M = {}
local check_states = {}

function M.enabled()
  if vim.fn.executable("rustup") ~= 1 then
    return false
  end

  return true
end

local function stop_timer(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

local function run_fly_check(bufnr, command)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd(("RustLsp flyCheck %s"):format(command))
  end)
end

local function rust_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr, name = "rust-analyzer" })[1]
end

function M.setup_check_scheduler(delay_ms)
  delay_ms = delay_ms or 5000

  for _, state in pairs(check_states) do
    stop_timer(state.timer)
  end
  check_states = {}

  local group = vim.api.nvim_create_augroup("rust_check_scheduler", { clear = true })

  local function cancel(bufnr)
    local client = rust_client(bufnr)
    local state = client and check_states[client.id]
    if not state then
      return
    end

    stop_timer(state.timer)
    state.timer = nil
    if state.running then
      run_fly_check(bufnr, "cancel")
      state.running = false
    end
  end

  local function schedule(bufnr, clear_diagnostics)
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "rust" then
      return
    end

    local client = rust_client(bufnr)
    if not client then
      return
    end

    local state = check_states[client.id] or {}
    check_states[client.id] = state
    stop_timer(state.timer)
    if state.running then
      run_fly_check(bufnr, "cancel")
      state.running = false
    end
    state.bufnr = bufnr

    if clear_diagnostics then
      vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(client.id), bufnr)
    end

    state.timer = vim.defer_fn(function()
      state.timer = nil
      local current_client = rust_client(state.bufnr)
      if not current_client or current_client.id ~= client.id then
        check_states[client.id] = nil
        return
      end

      state.running = true
      run_fly_check(state.bufnr, "run")
    end, delay_ms)
  end

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(event)
      schedule(event.buf, false)
    end,
  })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(event)
      schedule(event.buf, true)
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(event)
      if vim.bo[event.buf].filetype == "rust" then
        cancel(event.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(event)
      local client_id = event.data and event.data.client_id
      local state = client_id and check_states[client_id]
      if state then
        stop_timer(state.timer)
        check_states[client_id] = nil
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      for _, state in pairs(check_states) do
        stop_timer(state.timer)
      end
      check_states = {}
    end,
  })
end

return M
