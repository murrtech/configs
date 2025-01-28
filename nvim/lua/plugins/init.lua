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
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      -- Visual sign indicators in the left gutter
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "👉",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })

      -- Set up dap-ui
      dapui.setup {
        layouts = {
          {
            elements = {
              { id = "console", size = 1.0 },
            },
            size = 0.25,
            position = "bottom",
          },
          {
            elements = {
              { id = "scopes", size = 0.7 },
              { id = "watches", size = 0.1 },
              { id = "breakpoints", size = 0.1 },
              { id = "repl", size = 0.1 },
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

      -- codelldb adapter config
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- Simple directory-based detection:
      -- 1) Looks in "target/debug" for any files that are executable
      -- 2) If multiple, shows a simple list (no input validation)
      -- 3) If one, picks it automatically
      -- 4) Otherwise asks for your path
      local function guess_executable_in_target_debug()
        -- Where we'll look for built executables
        local debug_dir = "target/debug"

        -- Gather all files in 'target/debug'
        local files = vim.fn.glob(debug_dir .. "/*", true, true)
        if not files or #files == 0 then
          print("⚠️ No files found in " .. debug_dir .. ".")
          return vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
        end

        -- Filter only executables (not directories)
        local executables = {}
        for _, file in ipairs(files) do
          if vim.fn.executable(file) == 1 and vim.fn.isdirectory(file) == 0 then
            table.insert(executables, file)
          end
        end

        -- If none found, fall back to user input with no validation
        if #executables == 0 then
          print("⚠️ No executables found in " .. debug_dir .. ".")
          return vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
        end

        -- If exactly one found, pick it automatically
        if #executables == 1 then
          print("✅ Single executable found: " .. executables[1])
          return executables[1]
        end

        -- If more than one found, list them to the user (no validation of choice)
        local prompt = { "Multiple executables found in " .. debug_dir .. ":\nChoose a number:" }
        for i, exe in ipairs(executables) do
          table.insert(prompt, string.format("%d) %s", i, exe))
        end

        local choice = vim.fn.inputlist(prompt)
        local result = executables[choice]
        if result then
          print("✅ You chose: " .. result)
          return result
        else
          -- If invalid index or user hits <Esc>, prompt again
          print "⚠️ Invalid choice. Please type an exact path manually:"
          return vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
        end
      end

      -- Rust debug config using the directory-based approach
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = guess_executable_in_target_debug,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- Automatically open dap-ui on debug start
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.opt.wrap = false
      end

      -- Close dap-ui on debug termination or exit (with Insert or CursorMove)
      dap.listeners.before.event_terminated["dapui_config"] = function()
        vim.opt.wrap = true
        vim.cmd [[
        augroup DapUICloseOnKey
          autocmd!
          autocmd InsertEnter,CursorMoved * ++once lua require('dapui').close() vim.opt.wrap = true
        augroup END
      ]]
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        vim.opt.wrap = true
        vim.cmd [[
        augroup DapUICloseOnKey
          autocmd!
          autocmd InsertEnter,CursorMoved * ++once lua require('dapui').close() vim.opt.wrap = true
        augroup END
      ]]
      end

      -- Keymaps for controlling debugging sessions
      vim.keymap.set("n", "<leader>d", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })

      -- Additional helpful keymaps
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dC", function()
        dap.set_breakpoint(vim.fn.input "Condition: ")
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dL", function()
        dap.set_breakpoint(nil, nil, vim.fn.input "Log: ")
      end, { desc = "Debug: Log Point" })
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle({}, "vsplit")
      end, { desc = "Debug: Toggle REPL" })

      -- Hover to inspect variables
      vim.keymap.set("n", "K", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Value" })

      -- Close UI manually
      vim.keymap.set("n", "<leader>du", function()
        dapui.close()
      end, { desc = "Debug: Close UI" })
    end,
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

      --------------------------------------------------------------------------
      -- Visual Sign Definitions
      --------------------------------------------------------------------------
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "👉",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })

      --------------------------------------------------------------------------
      -- DAP UI Setup
      --------------------------------------------------------------------------
      dapui.setup {
        layouts = {
          {
            elements = {
              { id = "console", size = 1.0 },
            },
            size = 0.25,
            position = "bottom",
          },
          {
            elements = {
              { id = "scopes", size = 0.7 },
              { id = "watches", size = 0.1 },
              { id = "breakpoints", size = 0.1 },
              { id = "repl", size = 0.1 },
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

      --------------------------------------------------------------------------
      -- codelldb Adapter Configuration
      --------------------------------------------------------------------------
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      --------------------------------------------------------------------------
      -- Improved Crate/Executable Detection
      --------------------------------------------------------------------------
      -- 1) Build the entire workspace using "cargo build --workspace"
      -- 2) Use "cargo metadata" to discover packages and bin targets
      -- 3) For each binary target, see if "target/debug/<bin_name>" exists
      -- 4) If multiple exist, prompt user for which one to run (no strict validation)
      -- 5) If only one is found, use that automatically
      -- 6) If none are found, ask user to type the path
      --------------------------------------------------------------------------
      local function better_crate_selection()
        -- Build everything (add or remove flags as needed)
        print "⚙️ Building workspace ..."
        local build_output = vim.fn.system "cargo build --workspace"
        -- Optional: you can print(build_output) if you want more detail

        -- Parse cargo metadata
        local meta_json = vim.fn.system "cargo metadata --format-version=1 --no-deps"
        local ok, metadata = pcall(vim.fn.json_decode, meta_json)
        if not ok or not metadata then
          print "⚠️ Failed to parse cargo metadata. Falling back to manual path input."
          return vim.fn.input("Path to executable: ", "target/debug/", "file")
        end

        local debug_dir = metadata.target_directory .. "/debug"
        -- Gather all bin targets
        local bin_candidates = {}

        for _, pkg in ipairs(metadata.packages or {}) do
          for _, target in ipairs(pkg.targets or {}) do
            if vim.tbl_contains(target.kind, "bin") then
              local bin_path = debug_dir .. "/" .. target.name
              -- On Windows, you might check bin_path .. ".exe" or read from metadata
              if vim.fn.filereadable(bin_path) == 1 or vim.fn.executable(bin_path) == 1 then
                table.insert(bin_candidates, bin_path)
              end
            end
          end
        end

        -- If we found none, prompt user for a path
        if #bin_candidates == 0 then
          print("⚠️ No bin targets found or no matching executables in " .. debug_dir)
          return vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
        end

        -- If exactly one, just pick it
        if #bin_candidates == 1 then
          print("✅ Found single executable: " .. bin_candidates[1])
          return bin_candidates[1]
        end

        -- If multiple, show a quick list (no validation)
        print "🔎 Multiple executables found:"
        local prompt = { "Select a crate to debug:" }
        for i, exe in ipairs(bin_candidates) do
          table.insert(prompt, string.format("%d) %s", i, exe))
        end

        local choice = vim.fn.inputlist(prompt)
        local chosen = bin_candidates[choice]
        if chosen then
          print("✅ You chose: " .. chosen)
          return chosen
        else
          print "⚠️ Invalid choice. Please manually enter a path:"
          return vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
        end
      end

      --------------------------------------------------------------------------
      -- Rust DAP Configuration
      --------------------------------------------------------------------------
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = better_crate_selection, -- our function
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      --------------------------------------------------------------------------
      -- Auto-Open/Close DAP UI
      --------------------------------------------------------------------------
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.opt.wrap = false
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        vim.opt.wrap = true
        vim.cmd [[
        augroup DapUICloseOnKey
          autocmd!
          autocmd InsertEnter,CursorMoved * ++once lua require('dapui').close() vim.opt.wrap = true
        augroup END
      ]]
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        vim.opt.wrap = true
        vim.cmd [[
        augroup DapUICloseOnKey
          autocmd!
          autocmd InsertEnter,CursorMoved * ++once lua require('dapui').close() vim.opt.wrap = true
        augroup END
      ]]
      end

      --------------------------------------------------------------------------
      -- Keymaps
      --------------------------------------------------------------------------
      -- Basic debugging controls
      vim.keymap.set("n", "<leader>d", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })

      -- Conditional Breakpoint & Log
      vim.keymap.set("n", "<leader>dC", function()
        dap.set_breakpoint(vim.fn.input "Condition: ")
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dL", function()
        dap.set_breakpoint(nil, nil, vim.fn.input "Log: ")
      end, { desc = "Debug: Log Point" })

      -- REPL
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle({}, "vsplit")
      end, { desc = "Debug: Toggle REPL" })

      -- Hover to inspect variables
      vim.keymap.set("n", "K", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Value" })

      --------------------------------------------------------------------------
      -- "Kill" Debug Key (Terminate + Close UI)
      --------------------------------------------------------------------------
      vim.keymap.set("n", "<leader>dx", function()
        dap.terminate()
        -- Some adapters might also need a disconnect() call
        dap.disconnect { terminateDebuggee = true }
        dapui.close()
        print "💥 DAP session killed."
      end, { desc = "Debug: Kill Session" })
    end,
  },

  {
    "kyazdani42/nvim-web-devicons",
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
