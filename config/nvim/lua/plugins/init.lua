local plugins = {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup()
    end,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
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
      { 'nvim-tree/nvim-web-devicons', opt = true },
    },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto' }
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.configs.lspconfig")
    end,
  },
  -- syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("plugins.configs.treesitter")
    end,
  },
  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  -- completion support
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      -- Icon config ripped from lazyvim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/init.lua.
      -- May want to put this elsewhere or find how we can manage this as a package.
      local icons = {
        misc = {
          dots = "󰇘",
        },
        dap = {
          Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
          Breakpoint          = " ",
          BreakpointCondition = " ",
          BreakpointRejected  = { " ", "DiagnosticError" },
          LogPoint            = ".>",
        },
        diagnostics = {
          Error = " ",
          Warn  = " ",
          Hint  = " ",
          Info  = " ",
        },
        git = {
          added    = " ",
          modified = " ",
          removed  = " ",
        },
        kinds = {
          Array         = " ",
          Boolean       = "󰨙 ",
          Class         = " ",
          Codeium       = "󰘦 ",
          Color         = " ",
          Control       = " ",
          Collapsed     = " ",
          Constant      = "󰏿 ",
          Constructor   = " ",
          Copilot       = " ",
          Enum          = " ",
          EnumMember    = " ",
          Event         = " ",
          Field         = " ",
          File          = " ",
          Folder        = " ",
          Function      = "󰊕 ",
          Interface     = " ",
          Key           = " ",
          Keyword       = " ",
          Method        = "󰊕 ",
          Module        = " ",
          Namespace     = "󰦮 ",
          Null          = " ",
          Number        = "󰎠 ",
          Object        = " ",
          Operator      = " ",
          Package       = " ",
          Property      = " ",
          Reference     = " ",
          Snippet       = " ",
          String        = " ",
          Struct        = "󰆼 ",
          TabNine       = "󰏚 ",
          Text          = " ",
          TypeParameter = " ",
          Unit          = " ",
          Value         = " ",
          Variable      = "󰀫 ",
        },
      }

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(_, item)
            if icons.kinds[item.kind] then
              item.kind = icons.kinds[item.kind] .. item.kind
            end

            return item
          end,
        },
        --      experimental = {
        --        ghost_text = {
        --          hl_group = "CmpGhostText",
        --        },
        --      },
        sorting = defaults.sorting,
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      local cmp = require("cmp")
      cmp.setup(opts)

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      --      cmp.setup.cmdline(':', {
      --        mapping = cmp.mapping.preset.cmdline(),
      --        sources = cmp.config.sources({
      --          { name = 'path' }
      --        }, {
      --          { name = 'cmdline' }
      --        })
      --      })
    end,
  }
}

require("lazy").setup(plugins, require "plugins.configs.lazy")
