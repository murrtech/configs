---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "github_dark",
  theme_toggle = { "github_dark", "gruvbox" },
  transparency = false,
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
          return "%#St_dapInactive#󰐊  󰓛  ➜  󰆹  󰆸  󰳲 "
        end

        local status = ""
        if dap.session() then
          status = table.concat {
            "%#DapPlayButton#",
            "%@v:lua.require'configs.dap_handlers'.continue@ 󰐊 %X", -- Play (green)
            "%#DapStopButton#",
            "%@v:lua.require'configs.dap_handlers'.terminate@ 󰓛 %X", -- Stop (red)
            "%#DapStepButton#",
            "%@v:lua.require'configs.dap_handlers'.step_over@ ➜ %X", -- Step over (blue)
            "%#DapStepButton#",
            "%@v:lua.require'configs.dap_handlers'.step_into@ 󰆹 %X", -- Step into (blue)
            "%#DapStepButton#",
            "%@v:lua.require'configs.dap_handlers'.step_out@ 󰆸 %X", -- Step out (blue)
            "%#DapBreakpointButton#",
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@ 󰳲 %X", -- Breakpoint (red)
          }
        else
          status = table.concat {
            "%#St_dapInactive#",
            "%@v:lua.require'configs.dap_handlers'.continue@ 󰐊 %X",
            "%@v:lua.require'configs.dap_handlers'.terminate@ 󰓛 %X",
            "%@v:lua.require'configs.dap_handlers'.step_over@ ➜ %X",
            "%@v:lua.require'configs.dap_handlers'.step_into@ 󰆹 %X",
            "%@v:lua.require'configs.dap_handlers'.step_out@ 󰆸 %X",
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@ 󰳲 %X",
          }
        end
        return status
      end,
    },
  },
}

-- Initialize DAP listeners and keymaps
local init = function()
  local ok, dap = pcall(require, "dap")
  if ok then
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
