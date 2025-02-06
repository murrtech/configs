return {
  "MysticalDevil/inlay-hints.nvim",
  event = "LspAttach",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("inlay-hints").setup {
      autocmd = { enable = true },
      commands = { enable = true },
    }
  end,
}
