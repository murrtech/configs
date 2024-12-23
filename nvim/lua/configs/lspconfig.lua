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

-- Add keymaps for LSP features
vim.api.nvim_create_autocmd('LspAttach', {
 callback = function(ev)
   local opts = { buffer = ev.buf }
   vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, opts)
   vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
   vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
   vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
 end,
})

-- Your servers configuration
local servers = { "html", "cssls" }

-- Rust analyzer setup
lspconfig.rust_analyzer.setup {
 on_attach = nvlsp.on_attach,
 on_init = nvlsp.on_init,
 capabilities = nvlsp.capabilities,
 settings = {
   ['rust-analyzer'] = {
     checkOnSave = {
       command = "clippy"
     },
   }
 }
}

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
