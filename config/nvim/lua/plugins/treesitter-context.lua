return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "VeryLazy",
  opts = {
    enable = true,
    max_lines = 3,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
    zindex = 20,
  },
  config = function(_, opts)
    require("treesitter-context").setup(opts)
  end,
  keys = {
    {
      "<leader>ut",
      function()
        require("treesitter-context").toggle()
      end,
      desc = "Toggle Treesitter Context",
    },
    {
      "[c",
      function()
        require("treesitter-context").go_to_context()
      end,
      desc = "Go to Context",
    },
  },
}
