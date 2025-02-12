---@type ChadrcConfig
local M = {}

--------------------------------------------------------------------------------
-- 1. GLOBALS & DEBUG STATE
--------------------------------------------------------------------------------
_G.project_name = "NoProject"
_G.debug_active = false

--------------------------------------------------------------------------------
-- 2. LANGUAGE ICONS
--------------------------------------------------------------------------------
local lang_icons = {
  rust = "",
  lua = "",
  python = "",
  go = "",
  javascript = "",
  typescript = "",
  default = "",
}

--------------------------------------------------------------------------------
-- 3. CARGO.TOML PARSING FOR PROJECT NAME (unchanged from prior)
--------------------------------------------------------------------------------
local function find_nearest_cargo_toml(buf_path)
  -- If no buffer path, don't block
  if not buf_path or buf_path == "" then
    return nil
  end

  -- Try using vim.fs first (preferred method)
  if vim.fs and vim.fs.find and vim.fs.dirname then
    local cargo_files = vim.fs.find("Cargo.toml", {
      upward = true,
      path = vim.fs.dirname(buf_path),
      stop = vim.loop.os_homedir() or "/",
    })
    if cargo_files and cargo_files[1] then
      return cargo_files[1]
    end
    return nil -- Explicit nil return if not found
  end

  -- Fallback method
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

local function update_project_name_for_buffer()
  if _G.debug_active then
    return
  end

  -- Get buffer path safely
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    buf_path = vim.fn.expand "%:p"
  end

  -- Safely try to find Cargo.toml
  local ok, cargo_toml = pcall(find_nearest_cargo_toml, buf_path)
  if not ok or not cargo_toml then
    _G.project_name = "NoProject"
    return
  end

  -- Safely parse crate name
  local ok2, crate_name = pcall(parse_crate_name_from_cargo_toml, cargo_toml)
  if not ok2 or not crate_name then
    _G.project_name = "NoProject"
    return
  end

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

--------------------------------------------------------------------------------
-- 4. DAP LOGIC
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- 5. BUILDING TABUFLINE VIEWS
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- 6. TOGGLE NVIM TREE BUTTON
--    - We'll place a new module, "toggleNvimTree", to the right side (before "buffers" or "debugModule")
--    - Chosen icon: "" (Nerd Font for a folder-like icon). If it doesn't display, swap to another icon.
--------------------------------------------------------------------------------
_G.toggle_nvim_tree = function()
  vim.cmd "NvimTreeToggle"
end
vim.api.nvim_set_hl(0, "TreeToggle", { fg = "#ffffff", bg = "#282c34", bold = true })

-- 2. The function that builds your clickable tree toggle button with the new highlight.
--    The entire region (icon + spacing + separator) is clickable and uses the "TreeToggle" highlight group.
local function build_tree_toggle_button()
  return table.concat {
    "%@v:lua.toggle_nvim_tree@", -- begin clickable region
    "%#TreeToggle#", -- our custom highlight group
    "|   | ", -- icon + spacing + separator
    "%X", -- end clickable region
  }
end -----------------------------------------------------------------------------
-- 7. NVCHAD UI CONFIG
--------------------------------------------------------------------------------
M.ui = {
  tabufline = {
    lazyload = false,
    -- We insert "toggleNvimTree" module just before "buffers" in the order
    order = { "treeOffset", "toggleNvimTree", "buffers", "debugModule" },
    modules = {
      -- The new nvim-tree toggle module
      toggleNvimTree = function()
        return build_tree_toggle_button()
      end,

      -- The debug module we had previously
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

--------------------------------------------------------------------------------
-- 8. NVDASH SETTINGS
--------------------------------------------------------------------------------
M.nvdash = {
  load_on_startup = true,
}

--------------------------------------------------------------------------------
-- 9. MAPPINGS (OPTIONAL EXAMPLE)
--    If you want to ensure <leader>b toggles breakpoints, add it here or in another file
--------------------------------------------------------------------------------
M.mappings = {
  n = {
    ["<leader>b"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "Toggle DAP breakpoint",
    },
  },
}

return M
