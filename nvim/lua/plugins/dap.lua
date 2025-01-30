return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    ------------------------------------------------------------------------
    -- Imports
    ------------------------------------------------------------------------
    local dap = require "dap"
    local dapui = require "dapui"

    ------------------------------------------------------------------------
    -- Signs (visual indicators in the left gutter)
    ------------------------------------------------------------------------
    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine" })

    ------------------------------------------------------------------------
    -- nvim-dap-ui Setup
    ------------------------------------------------------------------------
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
            { id = "scopes", size = 0.6 },
            { id = "watches", size = 0.2 },
            { id = "breakpoints", size = 0.1 },
            { id = "repl", size = 0.1 },
          },
          size = 0.4,
          position = "right",
        },
      },
      -- Do NOT define custom icons here so we use the defaults from dap-ui
      controls = {
        enabled = true,
        element = "repl",
        -- No "icons" table => defaults from dap-ui
        mappings = {
          pause = "pause",
          play = "continue",
          step_into = "step_into",
          step_over = "step_over",
          step_out = "step_out",
          run_last = "run_last",
          terminate = "terminate",
          disconnect = "disconnect",
        },
      },
    }

    ------------------------------------------------------------------------
    -- nvim-dap-virtual-text Setup (Optional but useful)
    ------------------------------------------------------------------------
    require("nvim-dap-virtual-text").setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
    }

    ------------------------------------------------------------------------
    -- Function: Auto-detect which Rust binary to run
    ------------------------------------------------------------------------
    local function auto_detect_executable()
      print "⚙️ Building workspace with `cargo build --workspace`..."
      vim.fn.system "cargo build --workspace"

      local meta_json = vim.fn.system "cargo metadata --format-version=1 --no-deps"
      local ok, meta = pcall(vim.fn.json_decode, meta_json)
      if not ok or not meta then
        print "⚠️ Failed to parse cargo metadata. Provide path manually."
        return vim.fn.input("Path to executable: ", "target/debug/", "file")
      end

      local debug_dir = meta.target_directory .. "/debug"
      local bin_candidates = {}
      for _, pkg in ipairs(meta.packages or {}) do
        for _, tgt in ipairs(pkg.targets or {}) do
          if vim.tbl_contains(tgt.kind, "bin") then
            local exe = debug_dir .. "/" .. tgt.name
            if vim.fn.filereadable(exe) == 1 then
              table.insert(bin_candidates, exe)
            end
          end
        end
      end

      if #bin_candidates == 0 then
        return vim.fn.input("No bin found. Provide path manually: ", debug_dir .. "/", "file")
      elseif #bin_candidates == 1 then
        print("✅ Single bin found: " .. bin_candidates[1])
        return bin_candidates[1]
      else
        print "🔎 Multiple bin targets found:"
        local prompt = { "Select one to run under rr record:" }
        for i, exe in ipairs(bin_candidates) do
          table.insert(prompt, string.format("%d) %s", i, exe))
        end
        local choice = vim.fn.inputlist(prompt)
        return bin_candidates[choice] or vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
      end
    end

    ------------------------------------------------------------------------
    -- Adapter: rust_rr => "rr record <executable>"
    ------------------------------------------------------------------------
    -- This adapter is a function so we can dynamically set the command args
    dap.adapters.rust_rr = function(callback, config)
      local exe_path = config.program
      if not exe_path or exe_path == "" then
        exe_path = vim.fn.input("Path to executable: ", "target/debug/", "file")
      end

      callback {
        type = "executable",
        name = "rr-record",
        command = "rr",
        args = { "record", exe_path },
      }
    end

    ------------------------------------------------------------------------
    -- Configuration: run Rust with rr record
    ------------------------------------------------------------------------
    dap.configurations.rust = {
      {
        name = "RR: Record & Debug",
        type = "rust_rr",
        request = "launch",
        program = auto_detect_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    ------------------------------------------------------------------------
    -- Auto-Open/Close DAP UI
    ------------------------------------------------------------------------
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

    ------------------------------------------------------------------------
    -- Keymaps
    ------------------------------------------------------------------------
    -- Forward debugging
    vim.keymap.set("n", "<leader>d", dap.continue, { desc = "DAP Start/Continue" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out" })

    -- Reverse debugging
    vim.keymap.set("n", "<leader>drC", function()
      -- "Reverse Continue" isn't a built-in DAP request, so we call gdb directly:
      dap.run_command "exec-continue --reverse"
    end, { desc = "Reverse Continue" })

    -- Conditional and Log breakpoints
    vim.keymap.set("n", "<leader>dC", function()
      dap.set_breakpoint(vim.fn.input "Condition: ")
    end, { desc = "Conditional Breakpoint" })

    -- REPL and DAP UI
    vim.keymap.set("n", "<leader>dr", function()
      dap.repl.toggle({}, "vsplit")
    end, { desc = "Toggle REPL" })
    vim.keymap.set("n", "<leader>du", function()
      dapui.close()
    end, { desc = "Close DAP UI" })

    -- Hover to inspect variables
    vim.keymap.set("n", "K", function()
      require("dap.ui.widgets").hover()
    end, { desc = "DAP Hover Value" })

    -- If you want to forcibly kill the session
    vim.keymap.set("n", "<leader>dK", function()
      dap.terminate()
      dap.disconnect { terminateDebuggee = true }
      dapui.close()
      print "DAP session killed."
    end, { desc = "DAP Kill Session" })
  end,
}
