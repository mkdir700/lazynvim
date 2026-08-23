local M = {}

local function edited_buffers(workspace_edit)
  local buffers = {}

  for uri in pairs(workspace_edit.changes or {}) do
    buffers[vim.uri_to_bufnr(uri)] = true
  end

  for _, change in ipairs(workspace_edit.documentChanges or {}) do
    if change.textDocument and change.textDocument.uri then
      buffers[vim.uri_to_bufnr(change.textDocument.uri)] = true
    end
  end

  return buffers
end

function M.apply_and_save(workspace_edit, offset_encoding)
  local buffers = edited_buffers(workspace_edit)
  vim.lsp.util.apply_workspace_edit(workspace_edit, offset_encoding)

  for bufnr in pairs(buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified and vim.bo[bufnr].buftype == "" then
      local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
        vim.cmd("silent update")
      end)
      if not ok then
        vim.notify(
          ("Failed to save renamed file %s: %s"):format(vim.api.nvim_buf_get_name(bufnr), err),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

function M.setup()
  if M._setup then
    return
  end
  M._setup = true

  local original_handler = vim.lsp.handlers["textDocument/rename"]
  vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
    if err or not result then
      return original_handler(err, result, ctx, config)
    end

    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
    return M.apply_and_save(result, client.offset_encoding)
  end
end

return M
