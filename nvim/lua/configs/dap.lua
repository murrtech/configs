vim.cmd [[
 aunmenu PopUp
 nnoremenu PopUp.Toggle\ Breakpoint <cmd>lua require'dap'.toggle_breakpoint()<CR>
 nnoremenu PopUp.Conditional\ Breakpoint <cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
]]
