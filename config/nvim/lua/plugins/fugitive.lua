return {
  "tpope/vim-fugitive",
  cmd = "Git",
  keys = {
    { "<leader>G", "<cmd>Git<cr>", desc = "Git status" },
    { "<leader>ga", "<cmd>Git add -p<cr>", desc = "Git add -p" },
  },
}
