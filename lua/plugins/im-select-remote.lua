return {
  "mkdir700/im-select-remote.nvim",
  config = function()
    require("im-select-remote").setup({
      config = {
        socket = {
          command = "im-select -",
        },
      },
    })
  end,
}
