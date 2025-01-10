-- ~/.config/nvim/lua/custom/plugins.lua

return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
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
        "lua-language-server", "stylua",
        "html-lsp", "css-lsp", "prettier",
        "rust-analyzer" -- Add rust-analyzer for Rust language support
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "rust", "toml", "yaml", "python", "json" -- Add rust parser for syntax highlighting
      },
    },
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },
  {
    'saecki/crates.nvim',
    ft = { 'toml' },
    config = function()
      require('crates').setup()
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
            "%.git/.*",        -- Ignore all subfolders/files in .git
            "build/.*",        -- Ignore build folder recursively
            "target/.*",       -- Ignore all subfolders/files in target
            ".*%.lock",        -- Ignore lock files like yarn.lock or package-lock.json
          },
        },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      {
        "<leader>o",
        "<cmd>belowright Outline<CR>",
        desc = "Toggle outline"
      }
    },
    config = function()
      require("outline").setup({
        outline_window = {
          position = 'bottom',
          width = 25,
          auto_jump = true,
        }
      })
    end
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
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  }
}
