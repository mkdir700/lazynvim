return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "kana/vim-textobj-user",
    },
    {
      "kana/vim-textobj-entire",
    },
    {
      "kana/vim-textobj-indent",
    },
    {
      "kana/vim-textobj-line",
    },
    {
      "sgur/vim-textobj-parameter",
    },
    {
      "Julian/vim-textobj-variable-segment",
    },
  },
  ---@type TSConfig
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    highlight = {
      enable = true,
      use_languagetree = true,
      -- https://github.com/nvim-treesitter/nvim-treesitter/issues/1573
      additional_vim_regex_highlighting = { "python" },
    },
    
    indent = {
      disable = { "python", "yaml" },
      enable = true,
    },
    incremental_selection = {
      enable = false,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ad"] = "@conditional.outer",
          ["id"] = "@conditional.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<M-a>"] = "@parameter.inner",
        },
        swap_previous = {
          ["<M-A>"] = "@parameter.inner",
        },
      },
    },
  },
}
