-- 增强累加/累减
return {
  "monaqa/dial.nvim",
  event = "VeryLazy",
  config = function(_, opts)
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%Y年%-m月%-d日"],
        augend.constant.alias.bool,
        augend.constant.new({ elements = { "True", "False" } }), -- for python
        augend.constant.new({ elements = { "and", "or" } }), -- for python
        augend.constant.new({ elements = { "&&", "||" } }),
      },
    })
  end,
}
