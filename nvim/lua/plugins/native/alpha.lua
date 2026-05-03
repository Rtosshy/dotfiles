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

    -- The GIF is drawn by the terminal, not by alpha.nvim, so keep its target row
    -- in sync with the text layout above it.
    local function gif_row()
      return top_padding + #yoshi_vim_logo + gap_after_logo + 1
    end

    -- WezTerm accepts pixel sizes for inline images. Estimate the current cell
    -- size so the GIF scales with the Neovim window while keeping its aspect.
    local function yoshi_gif_size()
      local gif_aspect = 194 / 200
      local cell_width = 17
      local cell_height = 37
      local available_rows = math.max(8, vim.o.lines - gif_row() - 3)
      local width_cells = math.min(
        math.floor(vim.o.columns * 0.34),
        math.floor(available_rows * cell_height * gif_aspect / cell_width)
      )

      width_cells = math.max(18, math.min(width_cells, 34))

      local width_px = math.floor(width_cells * cell_width)
      local height_px = math.floor(width_px / gif_aspect)
      return {
        cells = width_cells,
        px = {
          width = width_px,
          height = height_px,
        },
      }
    end

    -- Send the animated GIF directly with the iTerm2 inline image protocol.
    local function yoshi_gif_sequence()
      local file = vim.fn.expand('~/ghq/github.com/Rtosshy/dotfiles/assets/yoshitv-yoshi.gif')
      local fd = io.open(file, 'rb')

      if not fd then
        vim.notify('Yoshi GIF was not found: ' .. file, vim.log.levels.ERROR)
        return nil
      end

      local data = fd:read('*a')
      fd:close()

      local gif_size = yoshi_gif_size()
      local gif_col = math.max(0, math.floor((vim.o.columns - gif_size.cells) / 2))

      return table.concat({
        '\27[s',
        ('\27[%d;%dH'):format(gif_row(), gif_col + 1),
        '\27]1337;File=',
        'name=',
        vim.base64.encode('yoshi.gif'),
        ';size=',
        tostring(#data),
        ';width=',
        tostring(gif_size.px.width),
        'px',
        ';height=',
        tostring(gif_size.px.height),
        'px',
        ';preserveAspectRatio=1',
        ';doNotMoveCursor=1',
        ';inline=1:',
        vim.base64.encode(data),
        '\7',
        '\27[u',
      })
    end

    -- Bypass the buffer and write the image escape sequence to the terminal UI.
    local function draw_yoshi_gif()
      local sequence = yoshi_gif_sequence()
      if not sequence then
        return
      end

      if vim.api.nvim_ui_send then
        vim.api.nvim_ui_send(sequence)
      else
        io.stdout:write(sequence)
      end
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
      -- Reserve vertical space for the terminal-drawn GIF before the buttons.
      { type = 'padding', val = 18 },
      dashboard.section.buttons,
    }

    alpha.setup(dashboard.config)

    local yoshi_group = vim.api.nvim_create_augroup('AlphaYoshiGif', { clear = true })
    -- Wait until alpha has drawn the text, then overlay the terminal-managed GIF.
    vim.api.nvim_create_autocmd('User', {
      group = yoshi_group,
      pattern = 'AlphaReady',
      callback = function()
        vim.defer_fn(draw_yoshi_gif, 80)
      end,
    })
    -- Other buffers (oil, etc.) overwrite the terminal-managed GIF, so resend it
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
            draw_yoshi_gif()
          end
        end, 80)
      end,
    })
    -- Resize clears terminal-managed image placements, so redraw alpha text and
    -- resend the GIF after Neovim/WezTerm finish resizing.
    vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
      group = yoshi_group,
      callback = function()
        if vim.bo.filetype == 'alpha' then
          pcall(alpha.redraw)
          vim.defer_fn(draw_yoshi_gif, 160)
        end
      end,
    })
  end,
}
