local M = {}

---@param sequence string
function M.send(sequence)
  if vim.api.nvim_ui_send then
    vim.api.nvim_ui_send(sequence)
  else
    io.stdout:write(sequence)
  end
end

return M
