-- lua/configs/lspconfig.lua
--
-- Minimal example of an NVChad-style config file for LSP servers *other* than Rust.
-- Since Rust is fully handled by RustaceanVim, we do NOT configure rust_analyzer here
-- to avoid duplicate servers.

require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- Example: Define which servers you'd like to configure by default
-- (excluding rust_analyzer if using RustaceanVim)
local servers = {
  "html",
  "cssls",
  "lua_ls", -- or "sumneko_lua" if you're on older setups
  "tsserver", -- if you have typescript-language-server installed via Mason
  -- add any other non-Rust servers you need
}

-- Apply a basic config to each server
for _, server_name in ipairs(servers) do
  lspconfig[server_name].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    -- You can place server-specific settings here. For instance:
    -- settings = { ... }
  }
end

-- If you want to override or extend something for a specific server,
-- you can do so below. For example:
-- lspconfig.lua_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
--   settings = {
--     Lua = {
--       diagnostics = {
--         globals = { "vim" },
--       },
--       workspace = {
--         library = vim.api.nvim_get_runtime_file("", true),
--       },
--     },
--   },
-- }
