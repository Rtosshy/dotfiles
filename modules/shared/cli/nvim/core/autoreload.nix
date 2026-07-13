_: {
  extraConfigLuaPost = ''
    -- Auto-reload files changed externally using libuv fs_event (like VSCode),
    -- instead of waiting for the next checktime (FocusGained etc.)
    local autoreload_watchers = {}

    local function autoreload_watch(bufnr)
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      if filepath == "" or autoreload_watchers[bufnr] then
        return
      end
      if not vim.uv.fs_stat(filepath) then
        return
      end

      local w = vim.uv.new_fs_event()
      if not w then
        return
      end

      w:start(
        filepath,
        {},
        vim.schedule_wrap(function(err)
          if err then
            return
          end

          -- Editors often save via write-to-temp + rename, which kills the
          -- watch on the old inode, so always stop and re-watch after settling
          if autoreload_watchers[bufnr] then
            autoreload_watchers[bufnr]:stop()
            autoreload_watchers[bufnr]:close()
            autoreload_watchers[bufnr] = nil
          end

          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end

          -- File deleted or renamed away: nothing to reload or watch
          local current_path = vim.api.nvim_buf_get_name(bufnr)
          if not vim.uv.fs_stat(current_path) then
            return
          end

          if not vim.bo[bufnr].modified then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("checktime")
            end)
          else
            vim.notify(
              ("%s changed on disk, but you have unsaved changes"):format(
                vim.fn.fnamemodify(current_path, ":t")
              ),
              vim.log.levels.WARN
            )
          end

          vim.defer_fn(function()
            autoreload_watch(bufnr)
          end, 100)
        end)
      )

      autoreload_watchers[bufnr] = w
    end

    local autoreload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

    vim.api.nvim_create_autocmd("BufReadPost", {
      group = autoreload_group,
      callback = function(args)
        autoreload_watch(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
      group = autoreload_group,
      callback = function(args)
        local w = autoreload_watchers[args.buf]
        if w then
          w:stop()
          w:close()
          autoreload_watchers[args.buf] = nil
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      group = autoreload_group,
      callback = function(args)
        vim.notify(
          ("%s reloaded from disk"):format(vim.fn.fnamemodify(args.file, ":t")),
          vim.log.levels.INFO
        )
      end,
    })
  '';
}
