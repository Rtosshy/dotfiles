local autocmd = vim.api.nvim_create_autocmd

autocmd('InsertLeave', { pattern = '*', command = 'set nopaste' })
autocmd('FileType', {
  pattern = { 'json', 'jsonc', 'jsonl' },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})
autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})
