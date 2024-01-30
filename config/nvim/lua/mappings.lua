local map = vim.keymap.set

-- defaults
map('n', '<Leader>nh', ':nohl<CR>', { desc = "Clear search highlighting" })

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>p", "<cmd> Telescope find_files <CR>")
map("n", "<leader>t", "<cmd> Telescope find_files hidden=true <CR>")
map("n", "<leader>fg", "<cmd> Telescope live_grep <CR>")
map("n", "<leader>fb", "<cmd> Telescope buffers <CR>")
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
map("n", "<leader>fh", "<cmd> Telescope help_tags <CR>")
map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")
