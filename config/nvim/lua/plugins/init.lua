local plugins = {
  "folke/which-key.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("plugins.configs.telescope")
    end
  },
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
  { 
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("plugins.configs.bufferline")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      {'nvim-tree/nvim-web-devicons', opt = true },
    },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto' }
      })
    end,
  },
}

require("lazy").setup(plugins, require "plugins.configs.lazy")
