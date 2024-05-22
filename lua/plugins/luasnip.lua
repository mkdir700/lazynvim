-- 使用文档
-- https://zjp-cn.github.io/neovim0.6-blogs/nvim/luasnip/doc1.html
return {
  "L3MON4D3/LuaSnip",
  keys = function()
    return {}
  end,
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local sn = ls.snippet_node
    local isn = ls.indent_snippet_node
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    local r = ls.restore_node
    local events = require("luasnip.util.events")
    local ai = require("luasnip.nodes.absolute_indexer")
    local extras = require("luasnip.extras")
    local fmt = extras.fmt
    local m = extras.m
    local l = extras.l
    local postfix = require("luasnip.extras.postfix").postfix

    local snippets = {
      all = {},
      lua = {},
      go = {},
      javascript = {},
      python = {
        -- postfix(".pr", {
        --   l("print(" .. l.POSTFIX_MATCH .. ")"),
        -- }, {
        --   condition = function()
        --     -- 仅在前面有字符的情况下才会触发
        --     if vim.fn.col(".") > 1 then
        --       return true
        --     end
        --   end,
        --   show_condition = function()
        --     return vim.fn.col(".") > 1
        --   end,
        -- }),
        -- -- s("glog", {
        -- --   t("import logging"),
        -- --   t({ "", "" }),
        -- --   t("logger = logging.getLogger("),
        -- --   i(1, "__name__"),
        -- --   t(")"),
        -- -- }),
        -- postfix(".li", {
        --   l("logger.info(" .. l.POSTFIX_MATCH .. ")"),
        -- }),
        -- postfix(".ld", {
        --   l("logger.debug(" .. l.POSTFIX_MATCH .. ")"),
        -- }),
        -- postfix(".le", {
        --   l("logger.error(" .. l.POSTFIX_MATCH .. ")"),
        -- }),
        -- postfix(".lw", {
        --   l("logger.warning(" .. l.POSTFIX_MATCH .. ")"),
        -- }),
        -- postfix(".lc", {
        --   l("logger.critical(" .. l.POSTFIX_MATCH .. ")"),
        -- }),
        -- el -> else:
        s("el", {
          t("else:"),
          -- new line,
          t({ "", "" }),
          t("\t"),
          i(1, "pass"),
        }),
        -- ei -> elif expression:
        s("ei", {
          t("elif "),
          i(1, "expression"),
          t(":"),
          -- new line,
          t({ "", "" }),
          t("\t"),
          i(2, "pass"),
        }),
      },
    }
    -- load snippets
    for lang, snippet in pairs(snippets) do
      ls.add_snippets(lang, snippet)
    end
  end,
}
