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
    theme = "vscode_colored",
    separator_style = "default",
    order = { "mode", "file", "%=", "lsp_msg", "%=", "lsp" },
  },
  tabufline = {
    order = { "treeOffset", "buffers", "tabs", "debug_icons" },
    modules = {
      debug_icons = function()
        local ok, dap = pcall(require, "dap")
        if not ok then
          return "%#St_dapInactive#󰐊 󰓛 ➜ 󰆹 󰆸 󰳲"
        end

        local status = ""
        if dap.session() then
          status = table.concat {
            "%@v:lua.require'configs.dap_handlers'.continue@%#DapPlayButton# 󰐊 %X", -- Play (green)
            "%@v:lua.require'configs.dap_handlers'.terminate@%#DapStopButton# 󰓛 %X", -- Stop (red)
            "%@v:lua.require'configs.dap_handlers'.step_over@%#DapStepButton# ➜ %X", -- Step over (blue)
            "%@v:lua.require'configs.dap_handlers'.step_into@%#DapStepButton# 󰆹 %X", -- Step into (blue)
            "%@v:lua.require'configs.dap_handlers'.step_out@%#DapStepButton# 󰆸 %X", -- Step out (blue)
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@%#DapBreakpointButton# 󰳲 %X", -- Breakpoint (red)
          }
        else
          status = table.concat {
            "%@v:lua.require'configs.dap_handlers'.continue@%#St_dapInactive# 󰐊 %X",
            "%@v:lua.require'configs.dap_handlers'.terminate@%#St_dapInactive# 󰓛 %X",
            "%@v:lua.require'configs.dap_handlers'.step_over@%#St_dapInactive# ➜ %X",
            "%@v:lua.require'configs.dap_handlers'.step_into@%#St_dapInactive# 󰆹 %X",
            "%@v:lua.require'configs.dap_handlers'.step_out@%#St_dapInactive# 󰆸 %X",
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@%#St_dapInactive# 󰳲 %X",
          }
        end
        return status
      end,
    },
  },
}

-- Function to set custom DAP highlight groups
local function set_dap_highlights()
  vim.api.nvim_set_hl(0, "DapPlayButton", { fg = "#00ff00", bold = true }) -- Bright green for play/continue
  vim.api.nvim_set_hl(0, "DapStopButton", { fg = "#ff4040", bold = true }) -- Bright red for stop
  vim.api.nvim_set_hl(0, "DapStepButton", { fg = "#00bfff", bold = true }) -- Deep sky blue for stepping
  vim.api.nvim_set_hl(0, "DapBreakpointButton", { fg = "#ff3333", bold = true }) -- Strong red for breakpoints
  vim.api.nvim_set_hl(0, "St_dapInactive", { fg = "#666666" }) -- Dark gray for inactive
end

-- Initialize DAP listeners, keymaps, and highlight groups
local init = function()
  local ok, dap = pcall(require, "dap")
  if ok then
    -- Apply the highlight groups immediately
    set_dap_highlights()

    -- Ensure highlights are re-applied on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = set_dap_highlights,
    })

    local function refresh_tabline()
      vim.cmd "redrawtabline"
    end

    dap.listeners.after.event_initialized["tabline_refresh"] = refresh_tabline
    dap.listeners.after.event_continued["tabline_refresh"] = refresh_tabline
    dap.listeners.after.event_terminated["tabline_refresh"] = refresh_tabline
    dap.listeners.after.event_exited["tabline_refresh"] = refresh_tabline
    dap.listeners.after.event_stopped["tabline_refresh"] = refresh_tabline
  end
end

M.init = init

return M
