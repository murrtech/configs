return {
  "folke/todo-comments.nvim",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>tt",
      "<cmd>TodoTrouble toggle focus=true<cr>",
      desc = "Diagnostics TODO",
    },
  },
  opts = {
    keywords = {
      FIX = {
        icon = " ",
        color = "error",
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
      },
      TODO = { icon = " ", color = "info" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      REVISIT = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
  },
}
