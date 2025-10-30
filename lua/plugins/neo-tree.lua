return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "s1n7ax/nvim-window-picker" },
  opts = {
    source_selector = {
      winbar = true,
      statusline = true,
    },
    window = {
      mappings = {
        ["<Tab>"] = "focus_preview",
        ["l"] = "open",
        ["S"] = "none",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        always_show = { ".git", "LICENSE", "README.md" },
        hide_by_name = {
          ".pytest_cache",
          ".mypy_cache",
          "__pycache__",
        },
        -- hide_by_pattern = { -- uses glob style patterns
        --   ".pytest_cache/*",
        -- },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          ".DS_Store",
          "thumbs.db",
          ".idea",
          ".ruff_cache",
        },
      },
    },
  },
  keys = function(_, keys)
    local function root_dir()
      return (LazyVim and LazyVim.root and (LazyVim.root.get and LazyVim.root.get() or LazyVim.root()))
        or vim.loop.cwd()
    end
    local function cwd_dir()
      return vim.loop.cwd() -- 或 vim.fn.getcwd()
    end
    local neotree = function(opts)
      return function()
        require("neo-tree.command").execute(vim.tbl_extend("force", { toggle = true }, opts or {}))
      end
    end

    -- 1) 先禁用 LazyVim/扩展里同名默认键，防止回弹
    for _, lhs in ipairs({ "<leader>e", "<leader>E", "<leader>fe", "<leader>fE" }) do
      table.insert(keys, { lhs, false, mode = "n" })
    end

    -- 2) 写入你想要的交换后的映射
    -- 你给出的需求：<leader>e / <leader>fe 打开 cwd；<leader>E / <leader>fE 打开 root
    table.insert(keys, { "<leader>e", neotree({ dir = cwd_dir() }), desc = "Explorer NeoTree (cwd)" })
    table.insert(keys, { "<leader>fe", neotree({ dir = cwd_dir() }), desc = "Explorer NeoTree (cwd)" })
    table.insert(keys, { "<leader>E", neotree({ dir = root_dir() }), desc = "Explorer NeoTree (root dir)" })
    table.insert(keys, { "<leader>fE", neotree({ dir = root_dir() }), desc = "Explorer NeoTree (root dir)" })

    return keys
  end,
}
