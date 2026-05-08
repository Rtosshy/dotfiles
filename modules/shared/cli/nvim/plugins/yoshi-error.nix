_: {
  programs.nixvim = {
    extraConfigLuaPost = ''
      local frame_dir = "${../../../../../assets/frames/yoshi-angry}"
      local frame_prefix = "yoshi-angry-"
      local frame_count = 38
      local frame_delay_ms = 60
      local image_cols = 14
      local image_rows = 7
      local image_id_base = 434343
      local cooldown_ms = 3000

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

      local function frame_file(frame)
        return ("%s/%s%02d.png"):format(frame_dir, frame_prefix, frame - 1)
      end

      local function delete_sequence()
        local chunks = {}
        for frame = 1, frame_count do
          chunks[#chunks + 1] = ("\27_Ga=d,d=i,i=%d,q=2\27\\"):format(image_id_base + frame)
        end
        return table.concat(chunks)
      end

      local function image_sequence(frame)
        local file = frame_file(frame)
        local fd = io.open(file, "rb")
        if not fd then
          return nil
        end
        fd:close()

        local image_id = image_id_base + frame
        local bottom_reserve = (vim.o.cmdheight or 1) + 1
        local row = math.max(1, vim.o.lines - image_rows - bottom_reserve + 1)
        local col = math.max(1, vim.o.columns - image_cols)

        return table.concat({
          "\27[s",
          ("\27[%d;%dH"):format(row, col),
          delete_sequence(),
          ("\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;"):format(image_id, image_cols, image_rows),
          vim.base64.encode(file),
          "\27\\",
          "\27[u",
        })
      end

      local function clear_image()
        send(delete_sequence())
      end

      local function play_once()
        local now = vim.loop.now()
        if now - last_trigger < cooldown_ms then
          return
        end
        last_trigger = now

        if running then
          return
        end
        running = true
        generation = generation + 1
        local gen = generation
        local frame = 1

        local function tick()
          if gen ~= generation then
            return
          end
          if frame > frame_count then
            running = false
            clear_image()
            return
          end
          local seq = image_sequence(frame)
          if seq then
            send(seq)
          end
          frame = frame + 1
          vim.defer_fn(tick, frame_delay_ms)
        end

        tick()
      end

      local original_notify = vim.notify
      vim.notify = function(msg, level, opts)
        if level == vim.log.levels.ERROR then
          vim.schedule(play_once)
        end
        return original_notify(msg, level, opts)
      end

      local last_errmsg = ""
      local errmsg_timer = (vim.uv or vim.loop).new_timer()
      errmsg_timer:start(0, 250, vim.schedule_wrap(function()
        local cur = vim.v.errmsg or ""
        if cur ~= "" and cur ~= last_errmsg then
          last_errmsg = cur
          play_once()
        elseif cur == "" then
          last_errmsg = ""
        end
      end))

      vim.api.nvim_create_user_command("YoshiAngry", play_once, {})

      vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
        callback = function()
          if running then
            generation = generation + 1
            running = false
            clear_image()
          end
        end,
      })
    '';
  };
}
