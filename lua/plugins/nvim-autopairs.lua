return {
  "windwp/nvim-autopairs",
  dependencies = { "hrsh7th/nvim-cmp" },
  event = "InsertEnter",
  opts = {
    map_c_w = true,
  }, -- this is equalent to setup({}) function
  config = function()
    -- local Rule = require('nvim-autopairs.rule')
    local npairs = require("nvim-autopairs")
    npairs.setup({})
  end,
}
