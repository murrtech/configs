---@type ChadrcConfig
local M = {}

--------------------------------------------------------------------------------
-- 1. UI OVERRIDES
--------------------------------------------------------------------------------

-- We'll keep the debug module as is, only ensuring it doesn't break <leader>b.
_G.project_name = "NoProject"
_G.debug_active = false

local lang_icons = {
  rust = "",
  lua = "",
  python = "",
  go = "",
  javascript = "",
  typescript = "",
  default = "",
}

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

local dap = require "dap"

local continue_icon = ""
local step_over_icon = ""
local step_in_icon = ""
local step_out_icon = ""
local stop_icon = ""
local restart_icon = ""

_G.my_dap_start = function()
  _G.debug_active = true
  local prev_session = dap.session()
  dap.continue()

  vim.defer_fn(function()
    local current_session = dap.session()
    if not current_session or current_session == prev_session then
      _G.debug_active = false
    end
  end, 250)
end

_G.my_dap_continue = function()
  dap.continue()
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

_G.my_dap_restart = function()
  local session = dap.session()
  if not session then
    print "No debug session to restart!"
    return
  end
  dap.terminate(nil, nil, function()
    dap.run_last()
  end)
end

dap.listeners.after.event_terminated["my_debug_listener"] = function()
  _G.debug_active = false
  update_project_name_for_buffer()
end
dap.listeners.after.event_exited["my_debug_listener"] = function()
  _G.debug_active = false
  update_project_name_for_buffer()
end

local function build_default_view()
  local ft = vim.bo.filetype or ""
  local lang_icon = lang_icons[ft] or lang_icons.default
  local crate_name = _G.project_name or "NoProject"

  return table.concat {
    "%@v:lua.my_dap_start@",
    "%#Identifier#",
    " ",
    continue_icon,
    " ",
    lang_icon,
    " ",
    crate_name,
    " ",
    "%X",
  }
end

local function build_debug_view()
  return table.concat {
    -- Continue
    "%@v:lua.my_dap_continue@",
    "%#Identifier#",
    " ",
    continue_icon,
    " ",
    "%X",
    " ",
    -- Restart
    "%@v:lua.my_dap_restart@",
    "%#Identifier#",
    " ",
    restart_icon,
    " ",
    "%X",
    " ",
    -- Step Over
    "%@v:lua.my_dap_step_over@",
    "%#Identifier#",
    " ",
    step_over_icon,
    " ",
    "%X",
    " ",
    -- Step In
    "%@v:lua.my_dap_step_in@",
    "%#Identifier#",
    " ",
    step_in_icon,
    " ",
    "%X",
    " ",
    -- Step Out
    "%@v:lua.my_dap_step_out@",
    "%#Identifier#",
    " ",
    step_out_icon,
    " ",
    "%X",
    " ",
    -- Stop
    "%@v:lua.my_dap_stop@",
    "%#Identifier#",
    " ",
    stop_icon,
    " ",
    "%X",
  }
end

M.ui = {
  tabufline = {
    lazyload = false,
    order = { "treeOffset", "buffers", "debugModule" },
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
    theme = "vscode_colored",
    separator_style = "default",
  },
}
M.nvdash = {
  load_on_startup = true,
}

return M
