require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

map("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "Find files using Telescope" })
map("n", "<leader>e", "<cmd> NvimTreeToggle <cr>", { desc = "NvimTreeToggle" })
map("n", "<leader>b", "<cmd> DapToggleBreakpoint <cr>", { desc = "Dap Toggle Breakpoint" })
map("n", "<leader>sn", "<cmd>!s_nvim<CR><cmd>qa!<CR>", { desc = "Sync Nvim configs" })
vim.keymap.set("n", "<leader>m", function()
  vim.cmd "popup PopUp"
  vim.cmd "normal! j"
end, { desc = "Open and focus the Right-Click Menu" })
