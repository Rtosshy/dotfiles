local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local function nmap(lhs, rhs, desc)
  map('n', lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
end

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
nmap('<C-s>', '<cmd>w<cr>', 'Save file')
nmap('<leader>sn', '<cmd>noautocmd w<cr>', 'Save file without autocommands')
nmap('<C-q>', '<cmd>q<cr>', 'Quit')
nmap('x', '"_x', 'Delete character without yank')
for _, key in ipairs({
  '<ScrollWheelUp>',
  '<ScrollWheelDown>',
  '<ScrollWheelLeft>',
  '<ScrollWheelRight>',
}) do
  map({ 'n', 'i', 'v', 's' }, key, '<Nop>', opts)
end
nmap('<C-d>', '<C-d>zz', 'Scroll down and center')
nmap('<C-u>', '<C-u>zz', 'Scroll up and center')
nmap('n', 'nzzzv', 'Next search result and center')
nmap('N', 'Nzzzv', 'Previous search result and center')
nmap('<Up>', '<cmd>resize -2<cr>', 'Decrease window height')
nmap('<Down>', '<cmd>resize +2<cr>', 'Increase window height')
nmap('<Left>', '<cmd>vertical resize -2<cr>', 'Decrease window width')
nmap('<Right>', '<cmd>vertical resize +2<cr>', 'Increase window width')
nmap(']b', '<cmd>bnext<cr>', 'Next buffer')
nmap('[b', '<cmd>bprevious<cr>', 'Previous buffer')
nmap('<leader>bx', '<cmd>bdelete<cr>', 'Delete buffer')
nmap('<leader>bo', '<cmd>BufferOnly<cr>', 'Delete other buffers')
nmap('<leader>w\\', '<C-w>v', 'Split window vertically')
nmap('<leader>w-', '<C-w>s', 'Split window horizontally')
nmap('<leader>w=', '<C-w>=', 'Equalize window sizes')
nmap('<leader>wo', '<cmd>only<cr>', 'Close other windows')
nmap('<leader>wx', '<cmd>close<cr>', 'Close window')
nmap('<C-k>', '<cmd>wincmd k<cr>', 'Focus window above')
nmap('<C-j>', '<cmd>wincmd j<cr>', 'Focus window below')
nmap('<C-h>', '<cmd>wincmd h<cr>', 'Focus window left')
nmap('<C-l>', '<cmd>wincmd l<cr>', 'Focus window right')
nmap('<leader>lw', '<cmd>set wrap!<cr>', 'Toggle line wrap')
map('v', '<', '<gv', vim.tbl_extend('force', opts, { desc = 'Indent left and reselect' }))
map('v', '>', '>gv', vim.tbl_extend('force', opts, { desc = 'Indent right and reselect' }))
map(
  'v',
  'p',
  '"_dP',
  vim.tbl_extend('force', opts, { desc = 'Paste without yanking replaced text' })
)

if vim.fn.has('mac') == 1 then
  nmap('<Esc>', function()
    vim.system({ 'macism', 'com.apple.keylayout.ABC' })
  end)
end
