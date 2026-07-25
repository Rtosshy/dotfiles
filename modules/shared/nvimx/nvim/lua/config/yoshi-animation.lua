local M = {}

function M.animation(opts)
  local generation = 0
  local running = false
  local last_trigger = 0

  local function send(sequence)
    if vim.api.nvim_ui_send then
      vim.api.nvim_ui_send(sequence)
    else
      io.stdout:write(sequence)
    end
  end

  local function delete_sequence()
    local chunks = {}
    for frame = 1, opts.frame_count do
      chunks[#chunks + 1] = ('\27_Ga=d,d=i,i=%d,q=2\27\\'):format(opts.image_id_base + frame)
    end
    return table.concat(chunks)
  end

  local function image_sequence(frame)
    local file = ('%s/%s%02d.png'):format(opts.frame_dir, opts.frame_prefix, frame - 1)
    local fd = io.open(file, 'rb')
    if not fd then
      return nil
    end
    fd:close()
    local bottom_reserve = (vim.o.cmdheight or 1) + 1
    local row = math.max(1, vim.o.lines - opts.image_rows - bottom_reserve + 1)
    local col = math.max(1, vim.o.columns - opts.image_cols)
    return table.concat({
      '\27[s',
      ('\27[%d;%dH'):format(row, col),
      delete_sequence(),
      ('\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;'):format(
        opts.image_id_base + frame,
        opts.image_cols,
        opts.image_rows
      ),
      vim.base64.encode(file),
      '\27\\',
      '\27[u',
    })
  end

  local function clear()
    send(delete_sequence())
  end

  local function play()
    local now = (vim.uv or vim.loop).now()
    if now - last_trigger < opts.cooldown_ms or running then
      return
    end
    last_trigger = now
    running = true
    generation = generation + 1
    local current_generation = generation
    local frame = 1
    local function tick()
      if current_generation ~= generation then
        return
      end
      if frame > opts.frame_count then
        running = false
        clear()
        return
      end
      local sequence = image_sequence(frame)
      if sequence then
        send(sequence)
      end
      frame = frame + 1
      vim.defer_fn(tick, opts.frame_delay_ms)
    end
    tick()
  end

  local function stop()
    if running then
      generation = generation + 1
      running = false
      clear()
    end
  end

  return { play = play, stop = stop }
end

return M
