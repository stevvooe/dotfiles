return {
  "christoomey/vim-tmux-navigator",
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Pane left" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Pane down" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Pane up" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Pane right" },
    { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Previous pane" },
  },
}
