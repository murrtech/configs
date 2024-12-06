
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
        "html", "css", "rust" -- Add rust parser for syntax highlighting
      },
    },
  },
  {
    "simrat39/rust-tools.nvim", -- Add rust-tools.nvim plugin for Rust development
    config = function()
      require("rust-tools").setup {
        server = {
          on_attach = function(_, bufnr)
            -- Add keymaps or other settings specific to Rust here
          end,
          settings = {
            ["rust-analyzer"] = {
              assist = {
                importGranularity = "module",
                importPrefix = "by_self",
              },
              cargo = {
                loadOutDirsFromCheck = true,
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      }
    end,
  },
  {
    "kyazdani42/nvim-web-devicons", -- Add nvim-web-devicons plugin for vscode-icons
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
          layout_config = {
            prompt_position = "top",  -- Position the input prompt at the top
            width = 0.8,             -- Adjust width as a percentage of the window
            height = 0.8,            -- Adjust height as a percentage of the window
            border = true,           -- Enable borders for the Telescope UI
          },
          sorting_strategy = "ascending", -- Show results in ascending order
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- Custom border characters
        },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    }
  
}
