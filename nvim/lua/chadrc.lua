-- chadrc.lua
-- Place this in your NVChad config (usually ~/.config/nvim/lua/custom/chadrc.lua)
--
-- If your entire bufferline is disappearing, it’s often because the default modules were removed
-- from the `order`. NVChad's tabufline has several built-in modules: "treeOffset", "buffers",
-- "tabs", "btns", etc. If you don't include them in the order, they won't display.
--
-- Below, we preserve the default modules AND add our new "debugModule" at the end.
-- This ensures the normal bufferline (buffers, tabs, close buttons) still appears.

local M = {}

--------------------------------------------------------------------------------
-- 1. GLOBAL STATE
--------------------------------------------------------------------------------
_G.project_name = "NoProject"
_G.debug_active = false

--------------------------------------------------------------------------------
-- 2. LANGUAGE ICONS (You can expand this to fit your needs)
--------------------------------------------------------------------------------
local lang_icons = {
  rust = "",
  lua = "",
  python = "",
  go = "",
  javascript = "",
  typescript = "",
  default = "",
}

--------------------------------------------------------------------------------
-- 3. PARSE CARGO PROJECT NAMES (Same logic as before)
--------------------------------------------------------------------------------
local function find_nearest_cargo_toml(buf_path)
  if buf_path == "" then
    buf_path = vim.fn.expand "%:p"
  end

  if vim.fs and vim.fs.find and vim.fs.dirname then
    local cargo_files = vim.fs.find("Cargo.toml", {
      upward = true,
      path = vim.fs.dirname(buf_path),
      stop = vim.loop.os_homedir() or "/",
    })
    if cargo_files and cargo_files[1] then
      return cargo_files[1]
    end
  end

  -- Fallback for older Neovim
  local sep = package.config:sub(1, 1)
  local function dirname(path)
    return path:match("(.*" .. sep .. ").-$") or path
  end
  local function is_root(dir)
    return (dir == "/" or dir:match "^%a:[/\\]$")
  end

  local dir = dirname(buf_path)
  while not is_root(dir) do
    local cargo_path = dir .. "Cargo.toml"
    if vim.loop.fs_stat(cargo_path) then
      return cargo_path
    end
    dir = dirname(dir:sub(1, #dir - 1))
  end
  return nil
end

local function parse_crate_name_from_cargo_toml(toml_path)
  if not toml_path then
    return "NoProject"
  end

  local file = io.open(toml_path, "r")
  if not file then
    return "NoProject"
  end

  local in_package_section = false
  local crate_name = "NoProject"
  for line in file:lines() do
    local stripped = line:gsub("^%s*(.-)%s*$", "%1")
    if stripped:match "^%[package%]" then
      in_package_section = true
    elseif in_package_section then
      local name_match = stripped:match [[^name%s*=%s*"(.-)"]]
      if name_match then
        crate_name = name_match
        break
      end
      if stripped:match "^%[.-%]" then
        break
      end
    end
  end
  file:close()
  return crate_name
end

local function update_project_name_for_buffer()
  if _G.debug_active then
    return
  end
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    buf_path = vim.fn.expand "%:p"
  end
  local cargo_toml = find_nearest_cargo_toml(buf_path)
  local crate_name = parse_crate_name_from_cargo_toml(cargo_toml)
  _G.project_name = crate_name
end

--------------------------------------------------------------------------------
-- 4. AUTO COMMANDS (Update project name, if not debugging)
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufWinEnter",
  "WinEnter",
  "TabEnter",
  "DirChanged",
  "FileType",
}, {
  callback = function()
    update_project_name_for_buffer()
  end,
})

--------------------------------------------------------------------------------
-- 5. DAP SETUP: LOGIC TO AVOID BAD STATE IF NO CONFIG SELECTED
--------------------------------------------------------------------------------

local dap = require "dap"

local step_over_icon = ""
local step_in_icon = ""
local step_out_icon = ""
local stop_icon = ""

_G.my_dap_start = function()
  _G.debug_active = true
  local prev_session = dap.session()
  dap.continue()

  -- Check after a short delay if a session actually started
  vim.defer_fn(function()
    local current_session = dap.session()
    if not current_session or current_session == prev_session then
      -- No debug session was chosen or started
      _G.debug_active = false
    end
  end, 250)
end

_G.my_dap_step_over = function()
  dap.step_over()
end
_G.my_dap_step_in = function()
  dap.step_into()
end
_G.my_dap_step_out = function()
  dap.step_out()
end
_G.my_dap_stop = function()
  dap.terminate()
end

dap.listeners.after.event_terminated["my_debug_listener"] = function()
  _G.debug_active = false
  update_project_name_for_buffer()
end

dap.listeners.after.event_exited["my_debug_listener"] = function()
  _G.debug_active = false
  update_project_name_for_buffer()
end

--------------------------------------------------------------------------------
-- 6. VIEWS: DEFAULT VS. DEBUG
--------------------------------------------------------------------------------
local function build_default_view()
  local ft = vim.bo.filetype or ""
  local lang_icon = lang_icons[ft] or lang_icons.default
  local crate_name = _G.project_name or "NoProject"

  return table.concat {
    "%@v:lua.my_dap_start@", -- begin clickable region for "start debug"
    "%#Identifier#",
    "  ", -- play icon
    lang_icon,
    " ",
    crate_name,
    " ",
    "%X", -- end clickable region
  }
end

local function build_debug_view()
  local debug_controls = {
    "%@v:lua.my_dap_step_over@",
    "%#Identifier#",
    " ",
    step_over_icon,
    " ",
    "%X",
    " ",
    "%@v:lua.my_dap_step_in@",
    "%#Identifier#",
    " ",
    step_in_icon,
    " ",
    "%X",
    " ",
    "%@v:lua.my_dap_step_out@",
    "%#Identifier#",
    " ",
    step_out_icon,
    " ",
    "%X",
    " ",
    "%@v:lua.my_dap_stop@",
    "%#Error#",
    " ",
    stop_icon,
    " ",
    "%X",
  }
  return table.concat(debug_controls)
end

--------------------------------------------------------------------------------
-- 7. NVCHAD TABUFLINE OVERRIDE
--    IMPORTANT: We preserve the existing modules: "treeOffset", "buffers", "tabs", "btns"
--    and THEN add "debugModule" last. That way, your bufferline is intact.
--------------------------------------------------------------------------------
M.ui = {
  tabufline = {
    lazyload = false,
    -- Keep default modules + inject our new "debugModule" at the end:
    order = {
      "treeOffset", -- show offset for nvim-tree if open
      "buffers", -- display open buffers
      "tabs", -- display tabs
      "btns", -- default close/new buttons
      "debugModule", -- our custom module
    },

    modules = {
      debugModule = function()
        if _G.debug_active then
          return build_debug_view()
        else
          return build_default_view()
        end
      end,
    },
  },

  statusline = {
    theme = "default",
    separator_style = "default",
  },
}

return M
