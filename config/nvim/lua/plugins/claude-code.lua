return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    {
      "<leader>ac",
      function()
        require("claude-code").toggle()
      end,
      desc = "Toggle Claude Code terminal",
    },
    {
      "<leader>cC",
      function()
        require("claude-code").toggle_with_args("--continue")
      end,
      desc = "Toggle Claude Code with --continue",
    },
    {
      "<leader>cV",
      function()
        require("claude-code").toggle_with_args("--verbose")
      end,
      desc = "Toggle Claude Code with --verbose",
    },
  },
  config = function()
    require("claude-code").setup()
  end,
}
