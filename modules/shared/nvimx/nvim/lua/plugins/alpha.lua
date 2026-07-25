-- Alpha dashboard and Yoshi animation.
return {
  {
    'goolord/alpha-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      local paths = require('config.paths')
      local logo = {
        [[ ██╗   ██╗  ██████╗  ███████╗ ██╗  ██╗ ██╗ ██╗   ██╗ ██╗ ███╗   ███╗]],
        [[ ╚██╗ ██╔╝ ██╔═══██╗ ██╔════╝ ██║  ██║ ██║ ██║   ██║ ██║ ████╗ ████║]],
        [[  ╚████╔╝  ██║   ██║ ███████╗ ███████║ ██║ ██║   ██║ ██║ ██╔████╔██║]],
        [[   ╚██╔╝   ██║   ██║ ╚════██║ ██╔══██║ ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║]],
        [[    ██║    ╚██████╔╝ ███████║ ██║  ██║ ██║  ╚████╔╝  ██║ ██║ ╚═╝ ██║]],
        [[    ╚═╝     ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚═╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
      }
      local top_padding = 2
      local gap_after_logo = 1
      local image_id_base = 424242
      local presets = {
        {
          weight = 1,
          frame_dir = paths.asset('frames/yoshi-walk-rainbow'),
          frame_prefix = 'yoshi-walk-rainbow-',
          frame_count = 14,
          frame_delay_ms = 100,
          image_cols = 34,
          image_rows = 16,
          colors = {
            '#ff5fa2',
            '#d050d8',
            '#9a3fd6',
            '#3a3ad6',
            '#3a8af0',
            '#3fd0d8',
            '#1fb39a',
            '#2fc44a',
            '#7ad84a',
            '#e0d83a',
            '#f0c83a',
            '#f0a830',
            '#f07a20',
            '#e83a2a',
          },
        },
        {
          weight = 9,
          frame_dir = paths.asset('frames/yoshi-walk-normal'),
          frame_prefix = 'yoshi-walk-normal-',
          frame_count = 8,
          frame_delay_ms = 120,
          image_cols = 40,
          image_rows = 14,
          colors = {
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
            '#7ad84a',
          },
        },
      }

      local function pick_preset()
        local total = 0
        for _, preset in ipairs(presets) do
          total = total + preset.weight
        end
        math.randomseed(os.time() + ((vim.uv or vim.loop).hrtime() % 1000000))
        local target, accumulated = math.random() * total, 0
        for _, preset in ipairs(presets) do
          accumulated = accumulated + preset.weight
          if target <= accumulated then
            return preset
          end
        end
        return presets[1]
      end

      local active = pick_preset()
      local current_frame = 1
      local running = false
      local generation = 0
      local function reroll()
        active = pick_preset()
        current_frame = 1
      end
      local function apply_color(frame)
        vim.api.nvim_set_hl(0, 'AlphaYoshiLogo', {
          fg = active.colors[frame] or active.colors[1],
          bold = true,
        })
      end
      local function delete_sequence()
        local chunks = {}
        for frame = 1, active.frame_count do
          chunks[#chunks + 1] = ('\27_Ga=d,d=i,i=%d,q=2\27\\'):format(image_id_base + frame)
        end
        return table.concat(chunks)
      end
      local function send(sequence)
        if vim.api.nvim_ui_send then
          vim.api.nvim_ui_send(sequence)
        else
          io.stdout:write(sequence)
        end
      end
      local function clear()
        send(delete_sequence())
      end
      local function draw(frame)
        local file = ('%s/%s%02d.png'):format(active.frame_dir, active.frame_prefix, frame - 1)
        local handle = io.open(file, 'rb')
        if not handle then
          vim.notify('Yoshi frame was not found: ' .. file, vim.log.levels.ERROR)
          return
        end
        handle:close()
        local row = top_padding + #logo + gap_after_logo + 1
        local col = math.max(0, math.floor((vim.o.columns - active.image_cols) / 2))
        send(table.concat({
          '\27[s',
          ('\27[%d;%dH'):format(row, col + 1),
          delete_sequence(),
          ('\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;'):format(
            image_id_base + frame,
            active.image_cols,
            active.image_rows
          ),
          vim.base64.encode(file),
          '\27\\',
          '\27[u',
        }))
        apply_color(frame)
      end
      local function start()
        if running then
          return
        end
        running = true
        generation = generation + 1
        local current_generation = generation
        local function tick()
          if current_generation ~= generation then
            return
          end
          if vim.bo.filetype ~= 'alpha' then
            running = false
            generation = generation + 1
            clear()
            return
          end
          draw(current_frame)
          current_frame = (current_frame % active.frame_count) + 1
          vim.defer_fn(tick, active.frame_delay_ms)
        end
        tick()
      end
      local function stop()
        if running then
          running = false
          generation = generation + 1
          clear()
        end
      end

      dashboard.section.buttons.val = {
        dashboard.button('e', '󰉋  Open directory', "<cmd>lua require('oil').toggle_float()<cr>"),
        dashboard.button('f', '  Find file', '<cmd>Telescope find_files hidden=true<cr>'),
        dashboard.button('r', '  Recent files', '<cmd>Telescope oldfiles<cr>'),
        dashboard.button('g', '󰊢  LazyGit', '<cmd>LazyGit<cr>'),
        dashboard.button('q', '  Quit', '<cmd>qa<cr>'),
      }
      apply_color(current_frame)
      dashboard.section.header.val = logo
      dashboard.section.header.opts = { hl = 'AlphaYoshiLogo', position = 'center' }
      dashboard.config.layout = {
        { type = 'padding', val = top_padding },
        dashboard.section.header,
        { type = 'padding', val = 18 },
        dashboard.section.buttons,
      }
      alpha.setup(dashboard.config)

      local group = vim.api.nvim_create_augroup('AlphaYoshiImage', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'AlphaReady',
        callback = function()
          reroll()
          apply_color(current_frame)
          vim.defer_fn(start, 80)
        end,
      })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        callback = function()
          if vim.bo.filetype ~= 'alpha' then
            return
          end
          reroll()
          apply_color(current_frame)
          vim.defer_fn(function()
            if vim.bo.filetype == 'alpha' then
              start()
            end
          end, 80)
        end,
      })
      vim.api.nvim_create_autocmd('BufLeave', { group = group, callback = stop })
      vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
        group = group,
        callback = function()
          if vim.bo.filetype == 'alpha' then
            pcall(alpha.redraw)
            vim.defer_fn(start, 160)
          end
        end,
      })
    end,
  },
}
