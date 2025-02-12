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
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" }, -- For .tf files
      tfvars = { "terraform_fmt" }, -- For .tfvars files
      hcl = { "terraform_fmt" }, -- For .hcl files
    },
    format_on_save = true,
    timeout_ms = 500,
  },
}
