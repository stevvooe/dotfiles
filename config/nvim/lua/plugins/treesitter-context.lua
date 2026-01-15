return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      enable = true,           -- enable by default
      max_lines = 3,           -- 0 = no limit
      min_window_height = 0,   -- disable in small windows if you want (e.g. 20)
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",    -- "inner" or "outer"
      mode = "cursor",         -- "cursor" or "topline"
      separator = nil,         -- e.g. "—"
      zindex = 20,

      -- If you only want it for certain languages:
      -- patterns = { default = { "class", "function", "method" } },
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)

      -- Optional: a highlight group tweak (keeps it subtle)
      -- vim.cmd("hi! link TreesitterContextLineNumber LineNr")
      -- vim.cmd("hi! link TreesitterContext Separator")
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
  },
}
