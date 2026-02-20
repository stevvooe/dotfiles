
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

-- terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- claude-code mappings
vim.keymap.set("n", "<leader>ac", function() require("claude-code").toggle() end, { desc = "Toggle Claude Code terminal" })
vim.keymap.set("n", "<leader>cC", function() require("claude-code").toggle_with_args("--continue") end, { desc = "Toggle Claude Code with --continue" })
vim.keymap.set("n", "<leader>cV", function() require("claude-code").toggle_with_args("--verbose") end, { desc = "Toggle Claude Code with --verbose" })

-- quickfix mappings
vim.keymap.set("n", "<M-j>", "<cmd> cnext <CR>")
vim.keymap.set("n", "<M-k>", "<cmd> cprev <CR>")
vim.keymap.set("n", "<M-q>", "<cmd> cclose <CR>", { desc = "Close quickfix list" })

-- git (fugitive)
vim.keymap.set("n", "<leader>G", "<cmd> Git <CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>ga", "<cmd> Git add -p <CR>", { desc = "Git add -p" })
