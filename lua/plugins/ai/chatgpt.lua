return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      actions_paths = {
        -- 拼接绝对路径, ./actions.json
        vim.fn.stdpath("config") .. "/lua/plugins/ai/actions.json",
      },
      chat = {
        keymaps = {
          close = { "q", "<c-c>" },
        },
      },
      openai_params = {
        model = "gpt-4o-mini",
        max_tokens = 3000,
      },
      openai_edit_params = {
        model = "gpt-4o-mini",
      },
    })

    local wk = require("which-key")
    wk.add({
      { "<leader>ac", group = "ChatGPT" },
      { "<leader>acc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
      {
        mode = { "n", "v" },
        { "<leader>aca", "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
        { "<leader>acd", "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" },
        { "<leader>ace", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
        { "<leader>acf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
        { "<leader>acg", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
        { "<leader>ack", "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" },
        { "<leader>acl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
        { "<leader>acn", "<cmd>ChatGPTRun better_variable_names<CR>", desc = "Better Variable Names" },
        { "<leader>aco", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
        { "<leader>acr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
        { "<leader>acs", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" },
        { "<leader>act", "<cmd>ChatGPTRun translate<CR>", desc = "Translate" },
        { "<leader>acx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
