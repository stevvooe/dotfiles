local map = vim.keymap.set

-- defaults
map('n', '<Leader>nh', ':nohl<CR>', { desc = "Clear search highlighting" })

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>p", "<cmd> Telescope find_files <CR>")
map("n", "<leader>P", "<cmd> Telescope find_files hidden=true <CR>")
map("n", "<leader>fg", "<cmd> Telescope live_grep <CR>")
map("n", "<leader>fb", "<cmd> Telescope buffers <CR>")
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
map("n", "<leader>fh", "<cmd> Telescope help_tags <CR>")
map("n", "<leader>d", "<cmd> Telescope diagnostics <CR>")
map("n", "<leader>D", "<cmd> Telescope diagnostics bufnr=0 <CR>")
map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- Diagnostics mappings for lsp.
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist)

-- Treeview control
map("n", "<leader>t", "<cmd> NvimTreeToggle <CR>")

-- buffer navigation
map("n", "<C-j>", "<cmd> bnext <CR>")
map("n", "<C-k>", "<cmd> bprev <CR>")
map("n", "<C-b>", "<cmd> Telescope buffers  <CR>")
map("n", "<leader>b", "<cmd> bnext <CR>")
map("n", "<leader>B", "<cmd> bprev <CR>")
