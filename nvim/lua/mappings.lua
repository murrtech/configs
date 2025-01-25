require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

map("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "Find files using Telescope" })
map("n", "<leader>e", "<cmd> NvimTreeToggle <cr>", { desc = "NvimTreeToggle" })
