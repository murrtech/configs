return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    {
      "<leader>o",
      "<cmd>belowright Outline<CR>",
      desc = "Toggle outline",
    },
  },
  config = function()
    require("outline").setup {
      outline_window = {
        position = "bottom",
        width = 25,
        auto_jump = true,
      },
    }
  end,
}
