-- 从文本中提取文件路径和行号
local function get_file_and_line(text)
  local file, line
  -- 匹配 Python traceback 格式
  file, line = text:match('File "(.+)", line (%d+)')
  if file and line then
    return file, line
  end

  -- 匹配类似 "/path/to/file.py:95: Error" 格式
  file, line = text:match("(.+):(%d+):")
  if file and line then
    return file, line
  end
  return nil, nil
end

-- 跳转到 traceback 对应的文件和行号
local function jump()
  local ok, flatten = pcall(require, "flatten")
  if not ok then
    vim.notify("flatten.nvim not found", vim.log.levels.ERROR)
    return
  end

  local traceback = vim.fn.getline(".")
  local file, line = get_file_and_line(traceback)
  -- 使用 flatten.nvim 的 edit_files 函数
  local edit_files = require("flatten.core").edit_files

  if file and line then
    edit_files({
      files = { file },
      guest_cwd = vim.fn.fnamemodify(file, ":h"),
      argv = { "nvim", "--embed", "+" .. line, file },
      force_block = false,
      stdin = {},
      response_pipe = vim.fn.tempname(),
    })
  else
    vim.notify("No valid traceback found in current line", vim.log.levels.WARN)
  end
end

-- 插件规范
return {
  {
    "traceback-jump",
    dependencies = {
      "willothy/flatten.nvim",
    },
    config = function()
      -- 在终端缓冲区中设置键位映射
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          local keymap_opts = {
            buffer = 0,
            noremap = true,
            desc = "Traceback Jump",
          }
          vim.keymap.set("n", "gF", jump, keymap_opts)
        end,
      })
    end,
  },
}
