return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Get the default components
      local components = opts.sections

      -- Create the debugger component
      local function debugger()
        local ok, dap = pcall(require, "dap")
        if not ok then
          return ""
        end

        if dap.session() then
          return table.concat {
            "%#St_dapBreakpoint#" .. " ▶ " .. "%*", -- continue
            "%#St_dapStop#" .. " ■ " .. "%*", -- terminate
            "%#St_dapOver#" .. " ⤼ " .. "%*", -- step over
            "%#St_dapInto#" .. " ⤴ " .. "%*", -- step into
            "%#St_dapOut#" .. " ⤵ " .. "%*", -- step out
          }
        end
        return ""
      end

      -- Replace the branch component with debugger in statusline
      components.lualine_c[1] = {
        debugger,
        color = { fg = "green", bg = "NONE" },
        padding = { left = 1, right = 1 },
      }

      -- Set up the refresh listeners
      local ok, dap = pcall(require, "dap")
      if ok then
        local function refresh_statusline()
          vim.cmd "redrawstatus"
        end

        dap.listeners.after.event_initialized["statusline_refresh"] = refresh_statusline
        dap.listeners.after.event_continued["statusline_refresh"] = refresh_statusline
        dap.listeners.after.event_paused["statusline_refresh"] = refresh_statusline
        dap.listeners.before.event_terminated["statusline_refresh"] = refresh_statusline
        dap.listeners.before.event_exited["statusline_refresh"] = refresh_statusline
      end

      return opts
    end,
  },
}
