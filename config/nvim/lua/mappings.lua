
-- defaults
vim.keymap.set('n', '<Leader>nh', ':nohl<CR>', { desc = "Clear search highlighting" })

-- telescope
vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
vim.keymap.set("n", "<leader>p", "<cmd> Telescope find_files <CR>")
vim.keymap.set("n", "<leader>P", "<cmd> Telescope find_files hidden=true <CR>")
vim.keymap.set("n", "<leader>fg", "<cmd> Telescope live_grep <CR>")
vim.keymap.set("n", "<leader>fb", "<cmd> Telescope buffers <CR>")
vim.keymap.set("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>")
vim.keymap.set("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- Replaced by trouble
-- vim.keymap.set("n", "<leader>d", "<cmd> Telescope diagnostics <CR>")
-- vim.keymap.set("n", "<leader>D", "<cmd> Telescope diagnostics bufnr=0 <CR>")

local trouble = require('trouble')
-- Trouble
-- TODO: diff these out with mappings in init.lua
vim.keymap.set("n", "<leader>d", "<cmd> Trouble diagnostics toggle <CR>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xw", "<cmd> Trouble diagnostics toggle <CR>", { desc = "Workspace diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xd", "<cmd> Trouble diagnostics toggle filter.buf=0 <CR>", { desc = "Buffer diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xq", "<cmd> Trouble qflist toggle <CR>", { desc = "Quickfix list (Trouble)" })
vim.keymap.set("n", "<leader>xl", "<cmd> Trouble loclist toggle <CR>", { desc = "Location list (Trouble)" })
vim.keymap.set("n", "gR", "<cmd> Trouble lsp toggle focus=false win.position=right <CR>", { desc = "LSP references (Trouble)" })

-- Diagnostics mappings for lsp.
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist)

-- Treeview control
vim.keymap.set("n", "<leader>t", "<cmd> NvimTreeToggle <CR>")

-- buffer navigation
vim.keymap.set("n", "<C-j>", "<cmd> bnext <CR>")
vim.keymap.set("n", "<C-k>", "<cmd> bprev <CR>")
vim.keymap.set("n", "<C-b>", "<cmd> Telescope buffers  <CR>")

-- claude-code mappings
vim.keymap.set("n", "<leader>ac", function() require("claude-code").toggle() end, { desc = "Toggle Claude Code terminal" })
vim.keymap.set("n", "<leader>cC", function() require("claude-code").toggle_with_args("--continue") end, { desc = "Toggle Claude Code with --continue" })
vim.keymap.set("n", "<leader>cV", function() require("claude-code").toggle_with_args("--verbose") end, { desc = "Toggle Claude Code with --verbose" })

-- quickfix mappings
vim.keymap.set("n", "<M-j>", "<cmd> cnext <CR>")
vim.keymap.set("n", "<M-k>", "<cmd> cprev <CR>")

-- git (fugitive)
vim.keymap.set("n", "<leader>G", "<cmd> Git <CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>ga", "<cmd> Git add -p <CR>", { desc = "Git add -p" })
