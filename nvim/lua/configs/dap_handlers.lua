local M = {}

M.continue = function()
  local dap = require "dap"
  if dap.session() and dap.session().stopped_thread_id then
    dap.continue()
  else
    dap.pause()
  end
end

M.terminate = function()
  require("dap").terminate()
end

M.step_over = function()
  require("dap").step_over()
end

M.step_into = function()
  require("dap").step_into()
end

M.step_out = function()
  require("dap").step_out()
end

M.toggle_breakpoint = function()
  require("dap").toggle_breakpoint()
end

return M
