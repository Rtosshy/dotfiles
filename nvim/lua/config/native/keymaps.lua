-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Ignore wheel events in Neovim. With mouse reporting disabled, some terminals
-- translate wheel input in the alternate screen to arrow keys instead.
vim.keymap.set({ 'n', 'i', 'v', 's' }, '<ScrollWheelUp>', '<Nop>', opts)
vim.keymap.set({ 'n', 'i', 'v', 's' }, '<ScrollWheelDown>', '<Nop>', opts)
vim.keymap.set({ 'n', 'i', 'v', 's' }, '<ScrollWheelLeft>', '<Nop>', opts)
vim.keymap.set({ 'n', 'i', 'v', 's' }, '<ScrollWheelRight>', '<Nop>', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Buffers
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', opts) -- go to next buffer
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', opts) -- go to previous buffer
vim.keymap.set('n', '<leader>bx', ':bdelete<CR>', opts) -- close buffer

-- Window management
vim.keymap.set('n', '<leader>wsv', '<C-w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>wsh', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>wse', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<leader>wx', ':close<CR>', opts) -- close current split window

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set(
  'n',
  '<leader>d',
  vim.diagnostic.open_float,
  { desc = 'Open floating diagnostic message' }
)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
