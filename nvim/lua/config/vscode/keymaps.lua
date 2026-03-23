vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

local opts = { noremap = true, silent = true }

vim.keymap.set('n', 'x', '"_x', opts)

vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

vim.keymap.set('n', '<leader>e', "<Cmd>call VSCodeNotify('workbench.view.explorer')<CR>", opts)

-- Chat をサイドバーで開く
-- vim.keymap.set("n", "<leader>c", "<Cmd>call VSCodeNotify('workbench.action.chat.openInSidebar')<CR>", opts)
-- パネルで開きたい場合は下記に切り替え
vim.keymap.set('n', '<leader>c', "<Cmd>call VSCodeNotify('workbench.action.chat.open')<CR>", opts)
