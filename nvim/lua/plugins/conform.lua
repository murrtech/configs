return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "rustfmt" },
      html = { "prettier" },
      python = { "black" },
      yaml = { "prettier" },
    },
    format_on_save = true,
    timeout_ms = 500,
  },
}
