return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
      { "<leader>gD", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: origin/main...HEAD" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File History (current file)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Repo History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
    },
    opts = function()
      local actions = require("diffview.actions")

      return {
        enhanced_diff_hl = true,
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
