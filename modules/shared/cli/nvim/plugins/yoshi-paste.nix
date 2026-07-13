_: {
  extraConfigLuaPost = ''
    local frame_dir = "${../../../../../assets/frames/yoshi-egg}"
    local frame_prefix = "yoshi-egg-"
    local frame_count = 44
    local frame_delay_ms = 40
    local image_cols = 20
    local image_rows = 11
    local image_id_base = 436000
    local cooldown_ms = 250

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

    -- expr マッピングでキーをその場に返す。
    -- feedkeys は typeahead の末尾に追加されるため、マクロ再生中は
    -- 残りのマクロキー(例: <C-a>)より後に p が実行されて順序が壊れる。
    -- expr ならマッピング位置で展開され、count / レジスタ指定もそのまま効く。
    local function put_with_yoshi(keys)
      return function()
        vim.defer_fn(play_once, 20)
        return keys
      end
    end

    vim.api.nvim_create_user_command("YoshiEgg", play_once, {})

    vim.keymap.set({ "n", "x" }, "p", put_with_yoshi("p"), { silent = true, expr = true })
    vim.keymap.set({ "n", "x" }, "P", put_with_yoshi("P"), { silent = true, expr = true })
    vim.keymap.set({ "n", "x" }, "gp", put_with_yoshi("gp"), { silent = true, expr = true })
    vim.keymap.set({ "n", "x" }, "gP", put_with_yoshi("gP"), { silent = true, expr = true })

    local yoshi_paste_group = vim.api.nvim_create_augroup("YoshiPasteAnimation", { clear = true })
    vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
      group = yoshi_paste_group,
      callback = function()
        if running then
          generation = generation + 1
          running = false
          clear_image()
        end
      end,
    })
  '';
}
