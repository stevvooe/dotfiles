return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
  },
  opts = {
    columns = {},
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["q"] = "actions.close",
    },
  },
}
