return {
  "altermo/ultimate-autopair.nvim",
  event = { "InsertEnter", "CmdlineEnter" },
  branch = "v0.6",
  opts = {
    {
      "<",
      ">",
      ft = { "rust" },
      cond = function(_, context)
        if context.key == ">" then
          return true
        end

        return context.line:sub(context.col - 1, context.col - 1):match("[%w_:]") ~= nil
      end,
    },
  },
}
