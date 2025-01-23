-- ~/.config/nvim/lua/custom/plugins.lua

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require "configs.conform"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "typescript-language-server",
        "emmet-ls",
        "json-lsp",
        "shfmt",
        "shellcheck",
        "rust-analyzer",
      },
    },
  },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },

  -- Example: Integrating RustaceanVim (rust-analyzer settings) with inlay-hints.nvim

  -- 1) Add/Configure the "inlay-hints.nvim" plugin
  {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("inlay-hints").setup {
        commands = { enable = true }, -- Adds :InlayHintsToggle / :InlayHintsEnable / :InlayHintsDisable
        autocmd = { enable = true }, -- Automatically attach inlay hints for all LSP servers that support them
      }
    end,
  },

  -- 2) Configure RustaceanVim so it applies your rust-analyzer settings
  --    If you *only* want the plugin's built-in autocmd to handle hints, you do NOT
  --    need to call `require("inlay-hints").on_attach(client, bufnr)` manually.

  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          -- If you want to override rust-analyzer inlay-hints config:
          settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = { enable = "never" },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = { enable = true },
                reborrowHints = { enable = "never" },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },

          -- If you prefer manual attachment rather than the built-in autocmd, do this:
          on_attach = function(client, bufnr)
            -- NVChad or user keymaps etc. go here
            -- Then manually enable the inlay-hints.nvim plugin:
            -- require("inlay-hints").on_attach(client, bufnr)
          end,
        },
      }
    end,
  },
  {
    "mhartington/formatter.nvim",
    lazy = false,
    config = function()
      -- Define the formatting logic for various file types
      require("formatter").setup {
        filetype = {
          rust = {
            -- Use rustfmt for Rust files
            function()
              return {
                exe = "rustfmt",
                args = { "--emit=stdout" },
                stdin = true,
              }
            end,
          },
          lua = {
            -- Use stylua for Lua files
            function()
              return {
                exe = "stylua",
                args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "-" },
                stdin = true,
              }
            end,
          },
          html = {
            -- Use prettier for HTML files
            function()
              return {
                exe = "prettier",
                args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                stdin = true,
              }
            end,
          },
          python = {
            -- Use black for Python files
            function()
              return {
                exe = "black",
                args = { "-" },
                stdin = true,
              }
            end,
          },
          yaml = {
            -- Use prettier for YAML files
            function()
              return {
                exe = "prettier",
                args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                stdin = true,
              }
            end,
          },
        },
      }

      -- Auto-format on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.rs", "*.lua", "*.html", "*.py", "*.yaml", "*.yml" },
        command = "FormatWrite",
      })
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    config = function()
      require("crates").setup()
    end,
  },

  {
    "kyazdani42/nvim-web-devicons", -- Add nvim-web-devicons plugin for vscode-icons
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      require("telescope").setup {
        defaults = {
          file_ignore_patterns = {
            "node_modules/.*", -- Ignore all subfolders/files in node_modules
            "%.git/.*", -- Ignore all subfolders/files in .git
            "build/.*", -- Ignore build folder recursively
            "target/.*", -- Ignore all subfolders/files in target
            ".*%.lock", -- Ignore lock files like yarn.lock or package-lock.json
          },
        },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      {
        "<leader>o",
        "<cmd>belowright Outline<CR>",
        desc = "Toggle outline",
      },
    },
    config = function()
      require("outline").setup {
        outline_window = {
          position = "bottom",
          width = 25,
          auto_jump = true,
        },
      }
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle focus=true<cr>",
        desc = "Diagnostics (Trouble)",
      },
    },
  },
}
