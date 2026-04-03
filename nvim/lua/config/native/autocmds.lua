-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste',
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'json', 'jsonc', 'jsonl' },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})
