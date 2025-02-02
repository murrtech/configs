---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "github_dark",
  theme_toggle = { "github_dark", "gruvbox" },
  transparency = false,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    -- Active debugging session colors
    St_dapContinue = { fg = "#98be65", bold = true }, -- Bright green
    St_dapStop = { fg = "#ff6c6b", bold = true }, -- Red
    St_dapStepOver = { fg = "#51afef", bold = true }, -- Blue
    St_dapStepInto = { fg = "#ecbe7b", bold = true }, -- Yellow
    St_dapStepOut = { fg = "#46d9ff", bold = true }, -- Cyan
    St_dapBreakpoint = { fg = "#da8548", bold = true }, -- Orange
    -- Inactive state - dimmer version
    St_dapInactive = { fg = "#545c7e" }, -- Muted gray
  },
}

M.nvdash = {
  load_on_startup = true,
}
M.ui = {
  statusline = {
    theme = "default",
    separator_style = "default",
    order = { "mode", "file", "dap_icons", "%=", "lsp_msg", "%=", "lsp", "cwd" },
    modules = {
      dap_icons = function()
        local ok, dap = pcall(require, "dap")
        if not ok then
          return "%#St_dapInactive#▶  󰑓  󰆹  󰆸  󰆿  󰃤 "
        end

        -- Create click handler string
        local function dap_click(action)
          return "%@v:lua.require'configs.dap_handlers'." .. action .. "@"
        end

        local status = ""
        if dap.session() then
          status = table.concat {
            "%#St_dapContinue#",
            dap.session().stopped_thread_id and "⏸" or "▶",
            dap_click "continue",
            "  ",

            "%#St_dapStop#󰑓",
            dap_click "terminate",
            "  ",

            "%#St_dapStepOver#󰆹",
            dap_click "step_over",
            "  ",

            "%#St_dapStepInto#󰆸",
            dap_click "step_into",
            "  ",

            "%#St_dapStepOut#󰆿",
            dap_click "step_out",
            "  ",

            "%#St_dapBreakpoint#󰃤",
            dap_click "toggle_breakpoint",
            "  ",
          }
        else
          status = table.concat {
            "%#St_dapInactive#",
            "▶",
            dap_click "continue",
            "  ",
            "󰑓",
            dap_click "terminate",
            "  ",
            "󰆹",
            dap_click "step_over",
            "  ",
            "󰆸",
            dap_click "step_into",
            "  ",
            "󰆿",
            dap_click "step_out",
            "  ",
            "󰃤",
            dap_click "toggle_breakpoint",
            "  ",
          }
        end
        return status
      end,
    },
  },
}
-- Initialize DAP listeners and keymaps (rest remains the same)
local init = function()
  local ok, dap = pcall(require, "dap")
  if ok then
    -- Debug actions
    vim.keymap.set("n", "<F5>", function()
      if dap.session() and dap.session().stopped_thread_id then
        dap.continue()
      else
        dap.pause()
      end
    end, { desc = "Debug: Continue/Pause" })

    vim.keymap.set("n", "<F17>", function()
      dap.terminate()
    end, { desc = "Debug: Stop" }) -- Shift+F5

    vim.keymap.set("n", "<F10>", function()
      dap.step_over()
    end, { desc = "Debug: Step Over" })

    vim.keymap.set("n", "<F11>", function()
      dap.step_into()
    end, { desc = "Debug: Step Into" })

    vim.keymap.set("n", "<F12>", function()
      dap.step_out()
    end, { desc = "Debug: Step Out" })

    vim.keymap.set("n", "<Leader>b", function()
      dap.toggle_breakpoint()
    end, { desc = "Debug: Toggle Breakpoint" })

    -- Refresh statusline on debug events
    local function refresh_statusline()
      vim.cmd "redrawstatus"
    end

    dap.listeners.after.event_initialized["statusline_refresh"] = refresh_statusline
    dap.listeners.after.event_continued["statusline_refresh"] = refresh_statusline
    dap.listeners.after.event_terminated["statusline_refresh"] = refresh_statusline
    dap.listeners.after.event_exited["statusline_refresh"] = refresh_statusline
    dap.listeners.after.event_stopped["statusline_refresh"] = refresh_statusline
  end
end

M.init = init

return M
