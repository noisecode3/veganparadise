vim.cmd('set shiftwidth=2')
local nvim_lsp = require('lspconfig')
nvim_lsp.java_language_server.setup{}
