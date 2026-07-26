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

---@param preset table
---@param frame integer
---@param layout table
---@param image_id_base integer
---@return boolean
function M.draw(preset, frame, layout, image_id_base)
  local file = ('%s/%s%02d.png'):format(preset.frame_dir, preset.frame_prefix, frame - 1)
  local handle = io.open(file, 'rb')
  if not handle then
    vim.notify('Yoshi frame was not found: ' .. file, vim.log.levels.ERROR)
    return false
  end
  handle:close()

  local row = layout.top_padding + layout.logo_line_count + layout.gap_after_logo + 1
  local col = math.max(0, math.floor((vim.o.columns - preset.image_cols) / 2))
  M.send(table.concat({
    '\27[s',
    ('\27[%d;%dH'):format(row, col + 1),
    M.delete_sequence(preset.frame_count, image_id_base),
    ('\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;'):format(
      image_id_base + frame,
      preset.image_cols,
      preset.image_rows
    ),
    vim.base64.encode(file),
    '\27\\',
    '\27[u',
  }))
  return true
end

return M
