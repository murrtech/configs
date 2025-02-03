---@type ChadrcConfig
local M = {}

-- Define the command early so that the clickable area in the statusline works:
vim.cmd [[command! NvimTreeToggle lua require("nvim-tree").toggle()]]

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
    order = { "nvim_tree_toggle", "treeOffset", "buffers", "debug_icons", "tabs", "btns" },
    modules = {
      nvim_tree_toggle = function()
        return "%@NvimTreeToggle<cr>@%#NvimTreeToggleIcon# %X"
      end,
      debug_icons = function()
        local ok, dap = pcall(require, "dap")
        if not ok then
          return "%#St_dapInactive#󰐊 󰓛 ➜ 󰆹 󰆸 󰳲  "
        end

        local status = ""
        if dap.session() then
          status = table.concat {
            "%@v:lua.require'configs.dap_handlers'.continue@%#DapPlayButton# 󰐊 %X",
            "%@v:lua.require'configs.dap_handlers'.terminate@%#DapStopButton# 󰓛 %X",
            "%@v:lua.require'configs.dap_handlers'.step_over@%#DapStepButton# ➜ %X",
            "%@v:lua.require'configs.dap_handlers'.step_into@%#DapStepButton# 󰆹 %X",
            "%@v:lua.require'configs.dap_handlers'.step_out@%#DapStepButton# 󰆸 %X",
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@%#DapBreakpointButton# 󰳲  %X",
          }
        else
          status = table.concat {
            "%@v:lua.require'configs.dap_handlers'.continue@%#St_dapInactive# 󰐊 %X",
            "%@v:lua.require'configs.dap_handlers'.terminate@%#St_dapInactive# 󰓛 %X",
            "%@v:lua.require'configs.dap_handlers'.step_over@%#St_dapInactive# ➜ %X",
            "%@v:lua.require'configs.dap_handlers'.step_into@%#St_dapInactive# 󰆹 %X",
            "%@v:lua.require'configs.dap_handlers'.step_out@%#St_dapInactive# 󰆸 %X",
            "%@v:lua.require'configs.dap_handlers'.toggle_breakpoint@%#St_dapInactive# 󰳲  %X",
          }
        end
        return status
      end,
    },
  },
}

local function set_dap_highlights()
  -- Active DAP icons with theme-compatible colors
  vim.api.nvim_set_hl(0, "DapPlayButton", { fg = "#98c379", bold = true }) -- Green
  vim.api.nvim_set_hl(0, "DapStopButton", { fg = "#e06c75", bold = true }) -- Red
  vim.api.nvim_set_hl(0, "DapStepButton", { fg = "#61afef", bold = true }) -- Blue
  vim.api.nvim_set_hl(0, "DapBreakpointButton", { fg = "#e06c75", bold = true }) -- Red

  -- Inactive state using theme's comment color
  vim.api.nvim_set_hl(0, "St_dapInactive", { fg = vim.g.base46.colors.comment })

  -- NvimTree toggle icon using folder color from theme
  vim.api.nvim_set_hl(0, "NvimTreeToggleIcon", { fg = vim.g.base46.colors.blue })
end

local function init()
  local ok, dap = pcall(require, "dap")
  if ok then
    set_dap_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        set_dap_highlights()
        vim.cmd "redrawtabline"
      end,
    })

    local refresh_tabline = function()
      vim.cmd "redrawtabline"
    end
    for _, event in ipairs { "event_initialized", "event_continued", "event_terminated", "event_exited", "event_stopped" } do
      dap.listeners.after[event]["tabline_refresh"] = refresh_tabline
    end
  end
end

M.init = init

return M
