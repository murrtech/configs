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
        "codelldb",
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
        autocmd = { enable = true },
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
        tools = {
          inlay_hints = {
            -- Show inlay hints only on the line where your cursor is
          },
        },

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
                -- etc.
              },
            },
          },
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
    "kyazdani42/nvim-web-devicons",
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require "configs.dap" -- Add this line
      local dap = require "dap"

      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      local dapui = require "dapui"

      -- DAP UI setup
      dapui.setup {
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.33 },
              { id = "breakpoints", size = 0.17 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 0.33,
            position = "right",
          },
          {
            elements = {
              { id = "repl", size = 0.45 },
              { id = "console", size = 0.55 },
            },
            size = 0.27,
            position = "bottom",
          },
        },
      }

      -- Automatically open UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.keymap.set("n", "<leader>dr", function()
        dap.reverse_step()
      end, { desc = "Debug: Reverse Step" })
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>dO", function()
        dap.step_out()
      end, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", function()
        dap.reverse_continue()
      end, { desc = "Debug: Reverse Continue" })
      vim.keymap.set("n", "<leader>dR", function()
        dap.reverse_step()
      end, { desc = "Debug: Reverse Step" })
      vim.keymap.set("n", "<leader>d", function()
        dap.continue()
      end, { desc = "Debug: Start/Launch" })

      -- Configure language-specific debuggers
      -- Example for Rust (requires codelldb)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          reverse = true,
        },
      }
    end,
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
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
}
