return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
    input = {
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
      },
    },
    terminal = {
      win = {
        keys = {
          hide_slash = false,
          hide_underscore = false,
        },
      },
    },
    picker = {
      actions = {
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = {
              after = { 0, 0 },
              style = "right_align",
              format = function(opts)
                local buf = vim.api.nvim_win_get_buf(opts.match.win)
                local line = vim.api.nvim_buf_get_lines(buf, opts.match.pos[1] - 1, opts.match.pos[1], false)[1] or ""
                local available = vim.api.nvim_win_get_width(opts.match.win) - vim.fn.strdisplaywidth(line)
                local fill = math.max(available - vim.fn.strdisplaywidth(opts.match.label), 0)
                local leader_hl = "SnacksPickerFlashLeader" .. opts.hl_group:gsub("[^%w]", "")
                local label_hl = vim.api.nvim_get_hl(0, { name = opts.hl_group, link = false })
                vim.api.nvim_set_hl(0, leader_hl, { fg = label_hl.bg or label_hl.fg })
                return {
                  { string.rep("·", fill), leader_hl },
                  { opts.match.label, opts.hl_group },
                }
              end,
            },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
      win = {
        input = { keys = { ["<C-w>"] = false } },
        list = { keys = { ["<C-w>"] = false } },
      },
    },
  },
  keys = {
    {
      "<leader>fr",
      function()
        require("util.recently_created").open()
      end,
      desc = "Recent",
    },
    {
      "<leader>sf",
      LazyVim.pick("files", {
        root = false,
        pattern = function(picker)
          return picker:word()
        end,
      }),
      desc = "Find Files (cwd)",
      mode = "x",
    },
    {
      "<leader>sF",
      LazyVim.pick("files", {
        pattern = function(picker)
          return picker:word()
        end,
      }),
      desc = "Find Files (Root Dir)",
      mode = "x",
    },
    { "<leader>sW", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    {
      "<leader>sw",
      LazyVim.pick("grep_word", { root = false }),
      desc = "Visual selection or word (cwd)",
      mode = { "n", "x" },
    },
    { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },  -- 谁在内部调用了我
    { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },  -- 我在内部调用了谁
  },
}
