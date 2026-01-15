return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      -- Open Diffview for working tree vs HEAD
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },

      -- Compare current branch against origin/main (change to origin/master if needed)
      { "<leader>gD", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: origin/main...HEAD" },

      -- File history for current file
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File History (current file)" },

      -- Repo history (all files)
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Repo History" },

      -- Close
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
    },
    opts = function()
      local actions = require("diffview.actions")

      return {
        enhanced_diff_hl = true,

        -- If you want tighter, more "vim-like" quit keys inside diffview:
        keymaps = {
          view = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
          },
          file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
            { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
            { "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage file" } },
            { "n", "S", actions.stage_all, { desc = "Stage all" } },
            { "n", "U", actions.unstage_all, { desc = "Unstage all" } },
            { "n", "R", actions.refresh_files, { desc = "Refresh" } },
          },
          file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
            { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
          },
        },
      }
    end,
  },
}
