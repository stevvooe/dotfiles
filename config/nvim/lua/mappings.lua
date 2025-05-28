
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
vim.keymap.set("n", "<leader>d", function() trouble.toggle() end)
vim.keymap.set("n", "<leader>xw", function() trouble.toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() trouble.toggle("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() trouble.toggle("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() trouble.toggle("loclist") end)
vim.keymap.set("n", "gR", function() trouble.toggle("lsp_references") end)

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
vim.keymap.set("n", "<leader>b", "<cmd> bnext <CR>")
vim.keymap.set("n", "<leader>B", "<cmd> bprev <CR>")

-- claude-code mappings
vim.keymap.set("n", "<leader>ac", function() require("claude-code").toggle() end, { desc = "Toggle Claude Code terminal" })
vim.keymap.set("n", "<leader>cC", function() require("claude-code").toggle_with_args("--continue") end, { desc = "Toggle Claude Code with --continue" })
vim.keymap.set("n", "<leader>cV", function() require("claude-code").toggle_with_args("--verbose") end, { desc = "Toggle Claude Code with --verbose" })
