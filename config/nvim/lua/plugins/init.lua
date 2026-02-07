return {
  { import = "plugins.colorscheme" },
  { import = "plugins.treesitter" },
  { import = "plugins.treesitter-context" },
  { import = "plugins.bufferline" },
  { import = "plugins.cmp" },
  { import = "plugins.lspconfig" },
  { import = "plugins.lazydev" },
  { import = "plugins.telescope" },
  { import = "plugins.which-key" },
  { import = "plugins.diffview" },
  { import = "plugins.gitsigns" },
  { import = "plugins.trouble" },
  { import = "plugins.lualine" },
  { import = "plugins.noice" },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "github/copilot.vim",
    cmd = "Copilot",
    config = function()
      vim.cmd("Copilot setup")
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = "Git"
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup()
    end
  },
}
