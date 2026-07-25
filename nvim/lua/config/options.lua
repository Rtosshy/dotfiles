local opt = vim.opt

opt.hlsearch = false
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 300
opt.backup = false
opt.writebackup = false
opt.termguicolors = true
opt.winblend = 0
opt.pumblend = 0
if vim.fn.exists('+winborder') == 1 then
  opt.winborder = 'rounded'
end
opt.whichwrap = 'bs<>[]hl'
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.listchars = { tab = '>>=', trail = '-', eol = '↵' }
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.numberwidth = 4
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.cursorline = false
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.smartindent = true
opt.showmode = false
opt.showtabline = 2
opt.backspace = 'indent,eol,start'
opt.pumheight = 10
opt.conceallevel = 0
opt.fileencoding = 'utf-8'
opt.cmdheight = 1
opt.autoindent = true
opt.completeopt = { 'menu', 'menuone', 'noselect' }

opt.shortmess:append('c')
opt.iskeyword:append('-')
opt.formatoptions:remove({ 'c', 'r', 'o' })
opt.runtimepath:remove('/usr/share/vim/vimfiles')
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
package.path = package.path .. ';' .. vim.fn.expand('$HOME') .. '/.luarocks/share/lua/5.1/?.lua;'
