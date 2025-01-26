vim.cmd [[
aunmenu PopUp

" Debug actions
anoremenu PopUp.Toggle\ Breakpoint <cmd>lua require'dap'.toggle_breakpoint()<CR>
anoremenu PopUp.Conditional\ Breakpoint <cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
anoremenu PopUp.Logpoint <cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log message: '))<CR>
anoremenu PopUp.-Sep1- :

" Debug control
anoremenu PopUp.Continue/Start <cmd>lua require'dap'.continue()<CR>
anoremenu PopUp.Step\ Over <cmd>lua require'dap'.step_over()<CR>
anoremenu PopUp.Step\ Into <cmd>lua require'dap'.step_into()<CR>
anoremenu PopUp.Step\ Out <cmd>lua require'dap'.step_out()<CR>
anoremenu PopUp.-Sep2- :

" Debug management
anoremenu PopUp.Close <cmd>lua require'dap'.close()<CR>
anoremenu PopUp.Terminate <cmd>lua require'dap'.terminate()<CR>
anoremenu PopUp.Clear\ Breakpoints <cmd>lua require'dap'.clear_breakpoints()<CR>
anoremenu PopUp.-Sep3- :

" LSP features
anoremenu PopUp.Definition <cmd>lua vim.lsp.buf.definition()<CR>
anoremenu PopUp.References <cmd>lua vim.lsp.buf.references()<CR>
anoremenu PopUp.Rename <cmd>lua vim.lsp.buf.rename()<CR>
anoremenu PopUp.Code\ Actions <cmd>lua vim.lsp.buf.code_action()<CR>
anoremenu PopUp.Format <cmd>lua vim.lsp.buf.format({ async = true })<CR>
anoremenu PopUp.-Sep4- :

" File operations
anoremenu PopUp.Save <cmd>write<CR>
anoremenu PopUp.Save\ All <cmd>wall<CR>
anoremenu PopUp.Close\ Buffer <cmd>bdelete<CR>
anoremenu PopUp.-Sep5- :

" Visual mode
vnoremenu PopUp.Evaluate <cmd>lua require'dap.ui.widgets'.preview()<CR>
vnoremenu PopUp.Format\ Selection <cmd>lua vim.lsp.buf.format({ async = true })<CR>
]]
