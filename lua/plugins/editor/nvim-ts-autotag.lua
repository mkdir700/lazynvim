return {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "vue", "xml" },
  config = function()
    require("nvim-ts-autotag").setup()
  end,
}
