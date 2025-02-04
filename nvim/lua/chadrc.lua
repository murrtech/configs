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
  },
}

return M
