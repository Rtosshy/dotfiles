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

local watchers = {}
local function watch(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' or watchers[bufnr] or not (vim.uv or vim.loop).fs_stat(filepath) then
    return
  end
  local watcher = (vim.uv or vim.loop).new_fs_event()
  if not watcher then
    return
  end
  watcher:start(
    filepath,
    {},
    vim.schedule_wrap(function(err)
      if err then
        return
      end
      if watchers[bufnr] then
        watchers[bufnr]:stop()
        watchers[bufnr]:close()
        watchers[bufnr] = nil
      end
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local current_path = vim.api.nvim_buf_get_name(bufnr)
      if not (vim.uv or vim.loop).fs_stat(current_path) then
        return
      end
      if not vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd('checktime')
        end)
      else
        vim.notify(
          ('%s changed on disk, but you have unsaved changes'):format(
            vim.fn.fnamemodify(current_path, ':t')
          ),
          vim.log.levels.WARN
        )
      end
      vim.defer_fn(function()
        watch(bufnr)
      end, 100)
    end)
  )
  watchers[bufnr] = watcher
end

local reload_group = vim.api.nvim_create_augroup('AutoReload', { clear = true })
autocmd('BufReadPost', {
  group = reload_group,
  callback = function(args)
    watch(args.buf)
  end,
})
autocmd('BufDelete', {
  group = reload_group,
  callback = function(args)
    local watcher = watchers[args.buf]
    if watcher then
      watcher:stop()
      watcher:close()
      watchers[args.buf] = nil
    end
  end,
})
autocmd('FileChangedShellPost', {
  group = reload_group,
  callback = function(args)
    vim.notify(
      ('%s reloaded from disk'):format(vim.fn.fnamemodify(args.file, ':t')),
      vim.log.levels.INFO
    )
  end,
})
