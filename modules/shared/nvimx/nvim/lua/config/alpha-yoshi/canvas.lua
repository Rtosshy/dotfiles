local M = {}

---@param sequence string
function M.send(sequence)
  if vim.api.nvim_ui_send then
    vim.api.nvim_ui_send(sequence)
  else
    io.stdout:write(sequence)
  end
end

---@param frame_count integer
---@param image_id_base integer
---@return string sequence
function M.delete_sequence(frame_count, image_id_base)
  local chunks = {}
  for frame = 1, frame_count do
    chunks[#chunks + 1] = ('\27_Ga=d,d=i,i=%d,q=2\27\\'):format(image_id_base + frame)
  end
  return table.concat(chunks)
end

---@param frame_count integer
---@param image_id_base integer
function M.clear(frame_count, image_id_base)
  M.send(M.delete_sequence(frame_count, image_id_base))
end

return M
