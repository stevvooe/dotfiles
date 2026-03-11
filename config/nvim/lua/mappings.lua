local map = vim.keymap.set

map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

map("n", "<leader>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>q", vim.diagnostic.setloclist)
map("n", "<leader>Q", vim.diagnostic.setqflist)

map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprev<CR>", { desc = "Previous buffer" })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<M-j>", "<cmd>cnext<CR>")
map("n", "<M-k>", "<cmd>cprev<CR>")
map("n", "<M-q>", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
