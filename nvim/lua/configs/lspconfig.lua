--------------------------------------------------------------------------------
-- Dynamically use each severity's sign icon as the inline prefix
-- and show no diagnostic message text. The hover float will still
-- display the full message on CursorHold/CursorHoldI events.
--------------------------------------------------------------------------------

require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- 1) Define signs for each diagnostic severity first
--    so we can reference them in the virtual_text.format function.
local signs = {
  Error = "", -- or "✗"
  Warn = "",
  Hint = "", -- lightbulb
  Info = "",
}

-- 2) Map numeric diagnostic severities to our sign keys
local severity_to_name = {
  [vim.diagnostic.severity.ERROR] = "Error",
  [vim.diagnostic.severity.WARN] = "Warn",
  [vim.diagnostic.severity.HINT] = "Hint",
  [vim.diagnostic.severity.INFO] = "Info",
}

-- 3) Configure nvim diagnostic output
vim.o.updatetime = 100

vim.diagnostic.config {
  virtual_text = {
    prefix = "", -- We'll provide the icon from format() instead
    spacing = -5, -- Space after the icon
    format = function(diagnostic)
      local sev_name = severity_to_name[diagnostic.severity]
      -- If for some reason there's no mapping, use a fallback bullet
      local icon = signs[sev_name] or "●"
      -- Return the icon only; no message text
      return icon
    end,
  },
  signs = true, -- Gutter icons
  underline = true, -- Undercurls
  update_in_insert = true,
  severity_sort = true,
  float = { border = "single" },
}

-- 4) Show the diagnostic float after pausing briefly in normal & insert modes
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
vim.api.nvim_create_autocmd("CursorHoldI", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- 5) Apply the gutter signs with their respective icons
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- 6) Undercurl highlights for each severity
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
  undercurl = true,
  sp = "#db4b4b",
})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
  undercurl = true,
  sp = "#e0af68",
})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
  undercurl = true,
  sp = "#10b981",
})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
  undercurl = true,
  sp = "#0db9d7",
})

-- 7) Example: standard servers (HTML, CSS) using NvChad defaults
local servers = { "html", "cssls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end
