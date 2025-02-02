return {
  "jonboh/nvim-dap-rr",
  dependencies = {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"
    local rr_dap = require "nvim-dap-rr"

    -- Configure the C++ adapter (adjust the path if not using Mason)
    local cpptools_path = vim.fn.stdpath "data" .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = cpptools_path,
    }

    -- Setup reverse debugging via nvim-dap-rr with custom mappings.
    -- NOTE: The mappings provided here will be applied when using rr for reverse debugging.
    rr_dap.setup {
      mappings = {
        continue = "<F7>",
        step_over = "<F8>",
        step_out = "<F9>",
        step_into = "<F10>",
        reverse_continue = "<F4>",
        reverse_step_over = "<F20>",
        reverse_step_out = "<F21>",
        reverse_step_into = "<F22>",
        step_over_i = "<F32>",
        step_out_i = "<F33>",
        step_into_i = "<F34>",
        reverse_step_over_i = "<F44>",
        reverse_step_out_i = "<F45>",
        reverse_step_into_i = "<F46>",
      },
    }

    -- Append the rr configurations to your existing language setups.
    dap.configurations.rust = dap.configurations.rust or {}
    table.insert(dap.configurations.rust, rr_dap.get_rust_config())

    dap.configurations.cpp = dap.configurations.cpp or {}
    table.insert(dap.configurations.cpp, rr_dap.get_config())

    -- Setup dap-ui with desired layouts and controls.
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

    -- Define visual signs for breakpoints and debugger states.
    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine" })

    -- Global key mappings for general DAP actions.
    -- IMPORTANT: Ensure these mappings do not conflict with the ones set in rr_dap.setup.
    -- For example, rr_dap.setup already maps <F7> to 'continue', so here we avoid remapping it.
    vim.keymap.set("n", "<F1>", dap.terminate, { desc = "Terminate Debug Session" })
    vim.keymap.set("n", "<F6>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
    vim.keymap.set("n", "<F11>", dap.pause, { desc = "Pause Execution" })
    vim.keymap.set("n", "<F56>", dap.down, { desc = "Navigate Down" })
    vim.keymap.set("n", "<F57>", dap.up, { desc = "Navigate Up" })

    vim.keymap.set("n", "<leader>d", dap.continue, { desc = "DAP Start/Continue" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP Step Out" })
    vim.keymap.set("n", "<leader>dx", function()
      dap.terminate()
      dap.disconnect { terminateDebuggee = true }
      dapui.close()
      print "DAP session closed."
    end, { desc = "Close DAP Session and UI" })

    -- Automatically open/close dap-ui on debugging events.
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
