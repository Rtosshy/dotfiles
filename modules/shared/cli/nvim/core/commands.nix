{
  extraConfigLua = ''
    vim.api.nvim_create_user_command("BufferOnly", function(opts)
      local current_buf = vim.api.nvim_get_current_buf()
      local deleted = 0

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.bo[buf].buflisted then
          local command = opts.bang and "bdelete! " or "confirm bdelete "
          local ok, err = pcall(vim.cmd, command .. buf)
          if not ok then
            vim.notify(err, vim.log.levels.WARN)
            return
          end

          if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted then
            deleted = deleted + 1
          else
            vim.notify("Buffer deletion was canceled", vim.log.levels.INFO)
            return
          end
        end
      end

      vim.notify(("Deleted %d buffer%s"):format(deleted, deleted == 1 and "" or "s"), vim.log.levels.INFO)
    end, {
      bang = true,
      desc = "Delete all listed buffers except the current buffer",
    })
  '';
}
