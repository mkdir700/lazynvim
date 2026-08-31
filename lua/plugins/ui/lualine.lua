return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local input_method = require("util.input_method_status")
    input_method.setup()

    local use_omarchy_theme = vim.fn.hostname() == "omarchy"
    opts.options.theme = use_omarchy_theme and "aether" or "everforest"
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }
    opts.extensions = vim.tbl_filter(function(extension)
      return extension ~= "neo-tree"
    end, opts.extensions or {})

    local colors
    if use_omarchy_theme then
      colors = require("aether.colorscheme")
    else
      local configuration = vim.fn["everforest#get_configuration"]()
      colors = vim.fn["everforest#get_palette"](configuration.background, configuration.colors_override)
    end
    table.insert(opts.sections.lualine_x, 1, {
      input_method.component,
      icon = "",
      cond = function()
        return vim.o.columns >= 80 and input_method.available()
      end,
      color = function()
        if use_omarchy_theme then
          return {
            fg = input_method.is_chinese() and colors.yellow or colors.green,
            bg = colors.dark_bg,
            gui = "bold",
          }
        end

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
