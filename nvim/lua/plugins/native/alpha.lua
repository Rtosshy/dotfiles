-- alpha-nvim config with colored Yoshi header
-- Place yoshi_header.lua in ~/.config/nvim/lua/yoshi_header.lua
-- Place this file as your alpha-nvim plugin spec

return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-mini/mini.icons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    local yoshi_vim_logo = {
      [[ ██╗   ██╗  ██████╗  ███████╗ ██╗  ██╗ ██╗ ██╗   ██╗ ██╗ ███╗   ███╗]],
      [[ ╚██╗ ██╔╝ ██╔═══██╗ ██╔════╝ ██║  ██║ ██║ ██║   ██║ ██║ ████╗ ████║]],
      [[  ╚████╔╝  ██║   ██║ ███████╗ ███████║ ██║ ██║   ██║ ██║ ██╔████╔██║]],
      [[   ╚██╔╝   ██║   ██║ ╚════██║ ██╔══██║ ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║]],
      [[    ██║    ╚██████╔╝ ███████║ ██║  ██║ ██║  ╚████╔╝  ██║ ██║ ╚═╝ ██║]],
      [[    ╚═╝     ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚═╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
    }

    local top_padding = 2
    local gap_after_logo = 1
    local yoshi_frame_count = 14
    local yoshi_frame_delay_ms = 100
    local yoshi_image_id_base = 424242
    local yoshi_current_frame = 1
    local yoshi_animation_running = false
    local yoshi_animation_generation = 0

    -- Ghostty supports Kitty graphics, but not Kitty animation frames. Animate by
    -- replacing static frame placements from Neovim so Ghostty and WezTerm share
    -- the same path. This has been verified on WezTerm and Ghostty.

    -- The image is drawn by the terminal, not by alpha.nvim, so keep its target row
    -- in sync with the text layout above it.
    local function yoshi_image_row()
      return top_padding + #yoshi_vim_logo + gap_after_logo + 1
    end

    -- Kitty graphics placements use terminal cells. Estimate the current cell
    -- size so the image scales with the Neovim window while keeping its aspect.
    local function yoshi_image_size()
      local image_aspect = 194 / 200
      local cell_width = 17
      local cell_height = 37
      local available_rows = math.max(8, vim.o.lines - yoshi_image_row() - 3)
      local cols = math.min(
        math.floor(vim.o.columns * 0.34),
        math.floor(available_rows * cell_height * image_aspect / cell_width)
      )

      cols = math.max(18, math.min(cols, 34))
      local rows = math.max(8, math.floor(cols * cell_width / image_aspect / cell_height))

      return {
        cols = cols,
        rows = rows,
      }
    end

    local function yoshi_frame_file(frame)
      return vim.fn.expand(
        ('~/ghq/github.com/Rtosshy/dotfiles/assets/yoshitv-yoshi-frames/yoshi-%02d.png'):format(
          frame - 1
        )
      )
    end

    local function yoshi_delete_sequence()
      local chunks = {}
      for frame = 1, yoshi_frame_count do
        chunks[#chunks + 1] = ('\27_Ga=d,d=i,i=%d,q=2\27\\'):format(yoshi_image_id_base + frame)
      end
      return table.concat(chunks)
    end

    -- Each tick deletes the previous frame placement and displays one PNG frame.
    -- This is intentionally client-driven instead of using Kitty's a=f/a=a
    -- animation commands because Ghostty currently ignores those frame controls.
    local function yoshi_image_sequence(frame)
      local file = yoshi_frame_file(frame)
      local fd = io.open(file, 'rb')

      if not fd then
        vim.notify('Yoshi frame was not found: ' .. file, vim.log.levels.ERROR)
        return nil
      end

      fd:close()

      local image_id = yoshi_image_id_base + frame
      local image_size = yoshi_image_size()
      local image_col = math.max(0, math.floor((vim.o.columns - image_size.cols) / 2))

      return table.concat({
        '\27[s',
        ('\27[%d;%dH'):format(yoshi_image_row(), image_col + 1),
        yoshi_delete_sequence(),
        ('\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;'):format(
          image_id,
          image_size.cols,
          image_size.rows
        ),
        vim.base64.encode(file),
        '\27\\',
        '\27[u',
      })
    end

    local function send_to_terminal(sequence)
      if vim.api.nvim_ui_send then
        vim.api.nvim_ui_send(sequence)
      else
        io.stdout:write(sequence)
      end
    end

    -- Bypass the buffer and write the image escape sequence to the terminal UI.
    local function draw_yoshi_frame(frame)
      local sequence = yoshi_image_sequence(frame)
      if sequence then
        send_to_terminal(sequence)
      end
    end

    local function clear_yoshi_image()
      send_to_terminal(yoshi_delete_sequence())
    end

    local function start_yoshi_animation()
      if yoshi_animation_running then
        return
      end

      yoshi_animation_running = true
      yoshi_animation_generation = yoshi_animation_generation + 1
      local generation = yoshi_animation_generation
      local function tick()
        if generation ~= yoshi_animation_generation then
          return
        end

        if vim.bo.filetype ~= 'alpha' then
          yoshi_animation_running = false
          yoshi_animation_generation = yoshi_animation_generation + 1
          clear_yoshi_image()
          return
        end

        draw_yoshi_frame(yoshi_current_frame)
        yoshi_current_frame = (yoshi_current_frame % yoshi_frame_count) + 1
        vim.defer_fn(tick, yoshi_frame_delay_ms)
      end

      tick()
    end

    dashboard.section.header.val = yoshi_vim_logo
    dashboard.section.header.opts = {
      hl = 'Type',
      position = 'center',
    }

    dashboard.section.buttons.val = {
      dashboard.button('o', '\u{f07c}  Open directory', '<cmd>Oil<cr>'),
      dashboard.button(
        'f',
        '\u{f002}  Find file',
        "<cmd>lua require('telescope.builtin').find_files()<cr>"
      ),
      dashboard.button(
        'r',
        '\u{f1da}  Recent files',
        "<cmd>lua require('telescope.builtin').oldfiles()<cr>"
      ),
      dashboard.button('g', '\u{f419}  LazyGit', '<cmd>LazyGit<cr>'),
      dashboard.button('q', '\u{f011}  Quit', '<cmd>qa<cr>'),
    }

    dashboard.config.layout = {
      { type = 'padding', val = top_padding },
      dashboard.section.header,
      -- Reserve vertical space for the terminal-drawn image before the buttons.
      { type = 'padding', val = 18 },
      dashboard.section.buttons,
    }

    alpha.setup(dashboard.config)

    local yoshi_group = vim.api.nvim_create_augroup('AlphaYoshiImage', { clear = true })
    -- Wait until alpha has drawn the text, then overlay the terminal-managed image.
    vim.api.nvim_create_autocmd('User', {
      group = yoshi_group,
      pattern = 'AlphaReady',
      callback = function()
        vim.defer_fn(start_yoshi_animation, 80)
      end,
    })
    -- Other buffers (oil, etc.) overwrite the terminal-managed image, so resend it
    -- whenever we re-enter the alpha buffer. Re-check the filetype inside the
    -- deferred callback in case the user already moved away during the delay.
    vim.api.nvim_create_autocmd('BufEnter', {
      group = yoshi_group,
      callback = function()
        if vim.bo.filetype ~= 'alpha' then
          return
        end
        vim.defer_fn(function()
          if vim.bo.filetype == 'alpha' then
            start_yoshi_animation()
          end
        end, 80)
      end,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
      group = yoshi_group,
      callback = function()
        if yoshi_animation_running then
          yoshi_animation_running = false
          yoshi_animation_generation = yoshi_animation_generation + 1
          clear_yoshi_image()
        end
      end,
    })
    -- Resize clears terminal-managed image placements, so redraw alpha text and
    -- resend the image after Neovim and the terminal finish resizing.
    vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
      group = yoshi_group,
      callback = function()
        if vim.bo.filetype == 'alpha' then
          pcall(alpha.redraw)
          vim.defer_fn(start_yoshi_animation, 160)
        end
      end,
    })
  end,
}
