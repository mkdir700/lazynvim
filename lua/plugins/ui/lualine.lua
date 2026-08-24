return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local input_method = require("util.input_method_status")
    input_method.setup()

    opts.options.theme = "everforest"
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }
    opts.extensions = vim.tbl_filter(function(extension)
      return extension ~= "neo-tree"
    end, opts.extensions or {})

    local configuration = vim.fn["everforest#get_configuration"]()
    local colors = vim.fn["everforest#get_palette"](configuration.background, configuration.colors_override)
    table.insert(opts.sections.lualine_x, 1, {
      input_method.component,
      icon = "",
      cond = function()
        return vim.o.columns >= 80 and input_method.available()
      end,
      color = function()
        return {
          fg = (input_method.is_chinese() and colors.yellow or colors.green)[1],
          bg = colors.bg3[1],
          gui = "bold",
        }
      end,
      separator = { left = "", right = "" },
      padding = { left = 1, right = 1 },
    })
  end,
}
