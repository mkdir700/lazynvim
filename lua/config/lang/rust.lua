local M = {}

function M.enabled()
  if vim.fn.executable("rustup") ~= 1 then
    return false
  end

  return true
end

function M.setup_diagnostic_reload()
  local group = vim.api.nvim_create_augroup("rust_diagnostics_external_reload", { clear = true })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(event)
      local bufnr = event.buf
      if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "rust" then
        return
      end
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust-analyzer" })
      if #clients == 0 then
        return
      end

      for _, client in ipairs(clients) do
        vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(client.id), bufnr)
      end

      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("RustLsp flyCheck clear")
        vim.cmd("RustLsp flyCheck run")
      end)
    end,
  })
end

return M
