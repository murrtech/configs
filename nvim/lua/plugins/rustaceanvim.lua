return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<F12>", function()
            vim.lsp.buf.definition()
          end, { buffer = bufnr, desc = "Go to Definition" })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            inlayHints = {
              only_current_line = true,
              bindingModeHints = { enable = false },
              closingBraceHints = { enable = true, minLines = 25 },
              lifetimeElisionHints = { enable = "never", useParameterNames = false },
              parameterHints = { enable = true },
              chainingHints = { enable = true },
              typeHints = { enable = true },
            },
          },
        },
      },
    }
  end,
}
