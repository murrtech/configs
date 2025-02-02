-- in lua/configs/dap_handlers.lua
local M = {}

M.continue = function()
  vim.schedule(function()
    require("dap").continue()
  end)
end

M.terminate = function()
  vim.schedule(function()
    require("dap").terminate()
  end)
end

M.step_over = function()
  vim.schedule(function()
    require("dap").step_over()
  end)
end

M.step_into = function()
  vim.schedule(function()
    require("dap").step_into()
  end)
end

M.step_out = function()
  vim.schedule(function()
    require("dap").step_out()
  end)
end

M.toggle_breakpoint = function()
  vim.schedule(function()
    require("dap").toggle_breakpoint()
  end)
end

return M
