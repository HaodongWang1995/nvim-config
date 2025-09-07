vim.opt.relativenumber=true
        
vim.opt.tabstop=2

vim.opt.shiftwidth=2

vim.opt.expandtab=true

vim.cmd('colorscheme habamax')

vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', '<Leader><CR>', ':so %<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>ex', ':Ex<CR>', { noremap = true, silent = true })


