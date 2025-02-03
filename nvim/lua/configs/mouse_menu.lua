vim.cmd [[
aunmenu PopUp
highlight Pmenu guibg=#1e1e2e guifg=#cdd6f4
highlight PmenuSel guibg=#45475a guifg=#cdd6f4
highlight PmenuSbar guibg=#313244
highlight PmenuThumb guibg=#585b70

" Edit
anoremenu PopUp.←\ Go\ Back <cmd>b#<CR>
anoremenu PopUp.⌨️\ Cut "+x
anoremenu PopUp.⌨️\ Copy "+y
anoremenu PopUp.⌨️\ Paste "+gP
anoremenu PopUp.⌨️\ Select\ All\ Copy ggVGy
anoremenu PopUp.-Sep1- :

" Debug
anoremenu PopUp.⚡\ Toggle\ Breakpoint <cmd>lua require'dap'.toggle_breakpoint()<CR>
anoremenu PopUp.⚡\ Continue/Start <cmd>lua require'dap'.continue()<CR>
anoremenu PopUp.⚡\ Conditional\ Breakpoint <cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
anoremenu PopUp.⚡\ Terminate <cmd>lua require'dap'.terminate()<CR>
anoremenu PopUp.⚡\ Logpoint <cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log message: '))<CR>
anoremenu PopUp.⚡\ Step\ Over <cmd>lua require'dap'.step_over()<CR>
anoremenu PopUp.⚡\ Step\ Into <cmd>lua require'dap'.step_into()<CR>
anoremenu PopUp.⚡\ Step\ Out <cmd>lua require'dap'.step_out()<CR>
anoremenu PopUp.⚡\ Clear\ Breakpoints <cmd>lua require'dap'.clear_breakpoints()<CR>
anoremenu PopUp.-Sep2- :

" LSP
anoremenu PopUp.🔍\ Definition <cmd>lua vim.lsp.buf.definition()<CR>
anoremenu PopUp.🔍\ References <cmd>lua vim.lsp.buf.references()<CR>
anoremenu PopUp.🔍\ Back <cmd>b#<CR>
anoremenu PopUp.🔍\ Code\ Actions <cmd>lua vim.lsp.buf.code_action()<CR>
anoremenu PopUp.-Sep3- :

" File
anoremenu PopUp.📁\ Save <cmd>write<CR>
anoremenu PopUp.📁\ Save\ All <cmd>wall<CR>
anoremenu PopUp.📁\ Close\ Buffer <cmd>bdelete<CR>
anoremenu PopUp.-Sep4- :

" Terminal
anoremenu PopUp.🖥️\ Sync\ Nvim <cmd>!s_nvim<CR><cmd>qa!<CR>
]]
