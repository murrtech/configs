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
  {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("inlay-hints").setup {
        -- Let it automatically attach to all servers that support inlay hints
        autocmd = { enable = true },
        -- Commands provide :InlayHintsToggle, :InlayHintsEnable, :InlayHintsDisable
        commands = { enable = true },
      }
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false, -- load immediately (or change to your preference)
    config = function()
      vim.g.rustaceanvim = {
        -- RustaceanVim uses rust-tools.nvim behind the scenes
        -- to configure & manage rust-analyzer.
        server = {
          -- If you prefer using Mason’s rust-analyzer, set:
          -- cmd = { vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer" },

          on_attach = function(client, bufnr)
            -- If you want to manually attach inlay-hints (instead of autocmd),
            -- uncomment this:
            -- require("inlay-hints").on_attach(client, bufnr)
          end,

          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy", -- or "cargo check"
              },
              diagnostics = {
                enable = true,
              },
              -- Tweak inlayHints to your liking:
              inlayHints = {
                -- Example: show chaining & parameter hints
                chainingHints = { enable = true },
                parameterHints = { enable = true },
                typeHints = { enable = true },
                bindingModeHints = { enable = false },
                reborrowHints = { enable = "never" },
                closureReturnTypeHints = { enable = "never" },
                maxLength = 25,
                renderColons = false,
              },
            },
          },
        },

        -- Additional RustaceanVim config if needed
        tools = {
          -- rust-tools-specific settings, e.g. hover actions or code lens
        },

        dap = {
          -- Debug settings if you want to configure nvim-dap
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
