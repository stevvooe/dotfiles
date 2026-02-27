return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>t", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
  },
  config = function()
    require("nvim-tree").setup()
  end,
}
