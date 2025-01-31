return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    ----------------------------------------------------------------------------
    -- 1) DAP UI + Virtual Text
    ----------------------------------------------------------------------------
    dapui.setup {
      layouts = {
        {
          elements = { { id = "console", size = 1.0 } },
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
      controls = {
        enabled = true,
        element = "repl",
      },
    }

    require("nvim-dap-virtual-text").setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
    }

    ----------------------------------------------------------------------------
    -- 2) Gutter Icons
    ----------------------------------------------------------------------------
    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine" })

    ----------------------------------------------------------------------------
    -- 3) Helper Functions
    ----------------------------------------------------------------------------
    local function pick_rust_bin()
      vim.fn.system "cargo build --workspace"
      local meta_json = vim.fn.system "cargo metadata --format-version=1 --no-deps"
      local ok, meta = pcall(vim.fn.json_decode, meta_json)
      if not ok or not meta then
        return vim.fn.input("Path to executable: ", "target/debug/", "file")
      end

      local debug_dir = meta.target_directory .. "/debug"
      local bins = {}
      for _, pkg in ipairs(meta.packages or {}) do
        for _, tgt in ipairs(pkg.targets or {}) do
          if vim.tbl_contains(tgt.kind, "bin") then
            local exe = debug_dir .. "/" .. tgt.name
            if vim.fn.filereadable(exe) == 1 then
              table.insert(bins, exe)
            end
          end
        end
      end

      if #bins == 0 then
        return vim.fn.input("No bin found. Provide path: ", debug_dir .. "/", "file")
      elseif #bins == 1 then
        return bins[1]
      else
        local prompt = { "Multiple bin targets found:" }
        for i, b in ipairs(bins) do
          prompt[#prompt + 1] = string.format("%d) %s", i, b)
        end
        local choice = vim.fn.inputlist(prompt)
        return bins[choice] or vim.fn.input("Path to executable: ", debug_dir .. "/", "file")
      end
    end

    local function gen_tmp_trace()
      local tmp = vim.fn.tempname()
      vim.fn.mkdir(tmp, "p")
      return tmp
    end

    ----------------------------------------------------------------------------
    -- 4) Record & Replay Adapters
    ----------------------------------------------------------------------------
    local rr_trace_dir = nil -- Store trace dir between sessions

    -- Adapter for recording
    dap.adapters.rust_rr_record = function(callback, config)
      local exe_path = config.program or "target/debug/your-crate"
      rr_trace_dir = config.trace_dir or gen_tmp_trace()

      local record_cmd = { "rr", "record", exe_path }

      local job_id = vim.fn.jobstart(record_cmd, {
        env = { RR_TRACE_DIR = rr_trace_dir },
        on_exit = function(_, code, _)
          if code == 0 then
            print("Recording complete. Trace dir: " .. rr_trace_dir)
          end
        end,
      })
    end

    -- Adapter for replay
    dap.adapters.rust_rr_replay = {
      type = "executable",
      command = "rr",
      args = { "replay", "--debugger", "gdb" },
      env = { RR_TRACE_DIR = rr_trace_dir },
    }

    ----------------------------------------------------------------------------
    -- 5) DAP Configurations
    ----------------------------------------------------------------------------
    dap.configurations.rust = {
      {
        name = "RR: Record",
        type = "rust_rr_record",
        request = "launch",
        program = pick_rust_bin,
        trace_dir = gen_tmp_trace(),
        cwd = "${workspaceFolder}",
      },
      {
        name = "RR: Replay Last Trace",
        type = "rust_rr_replay",
        request = "launch",
        cwd = "${workspaceFolder}",
        program = "${workspaceFolder}/target/debug/${workspaceFolderBasename}",
      },
    }

    ----------------------------------------------------------------------------
    -- 6) Keymaps
    ----------------------------------------------------------------------------
    vim.keymap.set("n", "<leader>dr", function()
      if not rr_trace_dir then
        vim.notify("No RR trace directory recorded!", vim.log.levels.ERROR)
        return
      end
      dap.run_config {
        type = "rust_rr_replay",
        name = "Replay Last",
        request = "launch",
        program = pick_rust_bin(),
        trace_dir = rr_trace_dir, -- Fixed from traceDir to trace_dir
      }
    end, { desc = "DAP Replay Last Trace" })

    vim.keymap.set("n", "<leader>d", dap.continue, { desc = "DAP Start/Continue" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP Step Out" })
    vim.keymap.set("n", "<leader>db", dap.step_back, { desc = "DAP Reverse Step" })

    vim.keymap.set("n", "<leader>drC", function()
      dap.run_command "exec-continue --reverse"
    end, { desc = "DAP Reverse Continue" })

    vim.keymap.set("n", "<leader>dC", function()
      dap.set_breakpoint(vim.fn.input "Condition: ")
    end, { desc = "Conditional Breakpoint" })

    vim.keymap.set("n", "<leader>dL", function()
      dap.set_breakpoint(nil, nil, vim.fn.input "Log: ")
    end, { desc = "Log Point" })

    vim.keymap.set("n", "<leader>dR", function()
      dap.repl.toggle({}, "vsplit")
    end, { desc = "DAP Toggle REPL" })

    vim.keymap.set("n", "<leader>du", function()
      dapui.close()
    end, { desc = "DAP Close UI" })

    vim.keymap.set("n", "K", function()
      require("dap.ui.widgets").hover()
    end, { desc = "DAP Hover" })

    vim.keymap.set("n", "<leader>dK", function()
      dap.terminate()
      dap.disconnect { terminateDebuggee = true }
      dapui.close()
      print "DAP session killed."
    end, { desc = "DAP Kill Session" })
  end,
}
