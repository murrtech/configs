-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()
local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- Configure diagnostic settings for real-time updates
vim.diagnostic.config({
  update_in_insert = true,  -- This enables real-time diagnostics in insert mode
  virtual_text = {
    prefix = "●",
    spacing = 4,
    source = "always",  -- Show source of diagnostic
  },
  float = {
    source = "always",  -- Show source in floating window
  },
  severity_sort = true,  -- Sort diagnostics by severity
})

-- Your servers configuration
local servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    flags = {
      debounce_text_changes = 50,  -- Reduce delay before sending changes to LSP
    },
  }
end