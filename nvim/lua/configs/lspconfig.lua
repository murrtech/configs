require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local signs = {
  Error = "",
  Warn = "",
  Hint = "",
  Info = "",
}

local severity_to_name = {
  [vim.diagnostic.severity.ERROR] = "Error",
  [vim.diagnostic.severity.WARN] = "Warn",
  [vim.diagnostic.severity.HINT] = "Hint",
  [vim.diagnostic.severity.INFO] = "Info",
}

vim.o.updatetime = 200

vim.diagnostic.config {
  virtual_text = false,
  signs = true, -- Gutter icons
  underline = true, -- Undercurls
  update_in_insert = true,
  severity_sort = true,
  float = { border = "single" },
}

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = cursor_pos[1] - 1
    local col = cursor_pos[2]
    local diagnostics = vim.diagnostic.get(0, { lnum = line })

    local show_float = false
    for _, d in ipairs(diagnostics) do
      if d.lnum == line and col >= d.col and col <= (d.end_col or d.col + 1) then
        show_float = true
        break
      end
    end

    if show_float then
      vim.diagnostic.open_float(nil, { focus = false })
    end
  end,
})
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
local servers = { "html", "cssls", "terraformls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

require("lspconfig").terraformls.setup {
  root_dir = function(fname)
    return require("lspconfig").util.root_pattern(".terraform", ".git", ".terraformrc", "terraform.rc")(fname)
      or vim.fn.getcwd()
  end,
}

-- 1) Save the original underline handler so we can wrap it.
local original_underline = vim.diagnostic.handlers.underline

-- 2) Override the underline handler.
vim.diagnostic.handlers.underline = {
  show = function(namespace, bufnr, diagnostics, opts)
    for _, diag in ipairs(diagnostics) do
      -- Check if the diagnostic has a valid .range
      if diag.range and diag.range["start"] and diag.range["end"] then
        local start_row = diag.range["start"].line
        local start_col = diag.range["start"].character
        local line_text = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

        if line_text then
          -- Attempt to find the first token in the line
          local sub = line_text:sub(start_col + 1)
          local first_token_start, first_token_end = sub:find "%S+"

          if first_token_start and first_token_end then
            local token_abs_start = start_col + first_token_start - 1
            local token_abs_end = start_col + first_token_end - 1

            -- Force the highlight range to just that token
            diag.range["start"].character = token_abs_start
            diag.range["end"].character = token_abs_end
          else
            -- If no token, highlight a single character
            diag.range["end"].character = start_col + 1
          end
        end
      end
    end

    -- Pass modified diagnostics to the original underline handler
    original_underline.show(namespace, bufnr, diagnostics, opts)
  end,

  hide = function(namespace, bufnr)
    original_underline.hide(namespace, bufnr)
  end,
}
