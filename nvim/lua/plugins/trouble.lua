return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
      desc = "Diagnostics Trouble",
    },
  },
}
