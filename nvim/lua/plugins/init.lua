-- ~/.config/nvim/lua/custom/plugins.lua

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "neovim/nvim-lspconfig",
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
        "rust-analyzer",
        "typescript-language-server",
        "emmet-ls",
        "json-lsp",
        "shfmt",
        "shellcheck",
      },
    },
  },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "rust",
        "toml",
        "yaml",
        "python",
        "json", -- Add rust parser for syntax highlighting
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
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
