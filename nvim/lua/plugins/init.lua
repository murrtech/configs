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
      require "configs.dap"
      local dap = require "dap"
      local dapui = require "dapui"

      -- Signs setup
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

      -- DAP UI setup
      dapui.setup {
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
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

      -- Rust configuration
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
          name = "cargo build",
          cargo = {
            args = { "build" },
            filter = {
              name = "cargo build",
              kind = "cargo-build",
            },
          },
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

            local current_file = vim.fn.expand "%:p"
            local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
            local crate_name = nil

            if cargo_toml ~= "" then
              local content = vim.fn.readfile(cargo_toml)
              for _, line in ipairs(content) do
                if line:match '^name%s*=%s*"(.+)"' then
                  crate_name = line:match '^name%s*=%s*"(.+)"'
                  break
                end
              end
            end

            if crate_name then
              for _, exe in ipairs(executables) do
                if exe:match(crate_name .. "$") then
                  return exe
                end
              end
            end

            return executables[1] or vim.fn.input("...Path to executable: ", debug_dir .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          reverse = true,
        },
      }

      -- UI handlers
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps
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
      vim.keymap.set("n", "<leader>dx", function()
        dap.terminate()
        dapui.close()
      end, { desc = "Debug: Stop and Close" })
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
              prompt_position = "top",
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
