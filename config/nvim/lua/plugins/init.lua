return {
  { import = "plugins.colorscheme" },
  { import = "plugins.treesitter" },
  { import = "plugins.bufferline" },
  { import = "plugins.cmp" },
  { import = "plugins.lspconfig" },
  { import = "plugins.neodev" },
  {  import = "plugins.telescope" },
  { import = "plugins.which-key" },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
              if vim.wo.diff then
                vim.cmd.normal({']c', bang = true})
              else
                gitsigns.nav_hunk('next')
              end
            end, { desc = "Gitsigns next hunk" })

            map('n', '[c', function()
              if vim.wo.diff then
                vim.cmd.normal({'[c', bang = true})
              else
                gitsigns.nav_hunk('prev')
              end
            end, { desc = "Gitsigns prev hunk" })

            -- Actions
            map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Gitsigns stage hunk" })
            map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Gitsigns reset hunk" })

            map('v', '<leader>hs', function()
              gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Gitsigns stage hunk" })

            map('v', '<leader>hr', function()
              gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = "Gitsigns reset hunk" })

            map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Gitsigns stage buffer" })
            map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Gitsigns reset buffer" })
            map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Gitsigns preview hunk" })
            map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Gitsigns preview hunk inline" })

            map('n', '<leader>hb', function()
              gitsigns.blame_line({ full = true })
            end, { desc = "Gitsigns blame line" })

            map('n', '<leader>hd', gitsigns.diffthis, { desc = "Gitsigns diff this" })

            map('n', '<leader>hD', function()
              gitsigns.diffthis('~')
            end, { desc = "Gitsigns diff this ~" })

            map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = "Gitsigns qflist all" })
            map('n', '<leader>hq', gitsigns.setqflist, { desc = "Gitsigns qflist" })

            -- Toggles
            map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Gitsigns toggle line blame" })
            map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = "Gitsigns toggle word diff" })

            -- Text object
            map({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Gitsigns select hunk" })
          end
        })
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opt = true },
    },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto' },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- provides relative filename
            },
          },
        }
      })
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
