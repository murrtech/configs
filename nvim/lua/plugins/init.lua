return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        html = { "prettier" },
        python = { "black" },
        yaml = { "prettier" },
      },
      format_on_save = true,
      timeout_ms = 500,
    },
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
        "emmet-ls",
        "json-lsp",
        "shfmt",
        "shellcheck",
        "rust-analyzer",
        "codelldb",
        "cpptools",
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
      local dap = require "dap"
      local dapui = require "dapui"

      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

      dapui.setup {
        layouts = {
          {
            elements = {
              { id = "repl", size = 1.0 },
            },
            size = 0.25,
            position = "bottom",
          },
          {
            elements = {
              { id = "scopes", size = 1.0 },
            },
            size = 0.4,
            position = "right",
          },
        },
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "→",
          pause = "⏸️",
          play = "▶️",
          step_into = "⤵️",
          step_over = "⏭️",
          step_out = "⤴️",
          step_back = "◀️",
          run_last = "🔄",
          terminate = "⏹️",
          disconnect = "⭘",
        },
        render = {
          max_type_length = 0,
          max_value_lines = 1,
          indent = 1,
          variable_style = "minimal",
          compact = true,
        },
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
      }

      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
      }

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
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            local output = vim.fn.system "cargo metadata --format-version 1 --no-deps"
            local metadata = vim.fn.json_decode(output)
            local target_dir = metadata.target_directory
            local debug_dir = target_dir .. "/debug"
            local files = vim.fn.glob(debug_dir .. "/*", true, true)
            local executables = vim.tbl_filter(function(file)
              return vim.fn.executable(file) == 1 and not vim.fn.isdirectory(file)
            end, files)
            return executables[1] or vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.opt.wrap = false
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        vim.opt.wrap = true
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        vim.opt.wrap = true
      end

      vim.keymap.set("n", "<leader>d", function()
        dap.continue()
      end, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "K", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Value" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      require("telescope").setup {
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = {
              height = 0.99,
              preview_cutoff = 0,
              prompt_position = "bottom",
              width = 0.9,
            },
          },
          file_ignore_patterns = {
            "node_modules/.*",
            "%.git/.*",
            "build/.*",
            "target/.*",
            ".*%.lock",
          },
          mappings = {
            i = {
              ["<CR>"] = "select_default_no_preview",
            },
          },
        },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>tt",
        "<cmd>TodoTrouble toggle focus=true<cr>",
        desc = "Diagnostics TODO",
      },
    },
    opts = {
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = { icon = " ", color = "info" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        REVISIT = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
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
        desc = "Diagnostics Trouble",
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
