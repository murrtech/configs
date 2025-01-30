return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = true },
  },
  config = function()
    require("nvchad.configs.lspconfig").defaults()
    require "configs.lspconfig"
  end,
}
