return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>P", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find hidden files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Find old files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
      { "<leader>gt", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<C-b>", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          hidden = true,
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },
}
