-- nvim-dap configuration: integrates dap-ui and virtual text for a complete debugging experience
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    -- Configure dap-ui layouts for console and side panels
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

    -- Setup virtual text to display variable values inline
    require("nvim-dap-virtual-text").setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
    }

    -- Define custom signs for breakpoints and debugging states
    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DapStopped", linehl = "DapStoppedLine" })

    -- Set up additional key mappings for dap actions
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

    -- Automatically open and close dap-ui with debugging events
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
