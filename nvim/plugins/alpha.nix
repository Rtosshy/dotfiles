{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      alpha-nvim
    ];

    extraConfigLuaPost = ''
      local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

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

        local function yoshi_image_row()
          return top_padding + #yoshi_vim_logo + gap_after_logo + 1
        end

        local function yoshi_image_size()
          return {
            cols = 34,
            rows = 16,
          }
        end

        local function yoshi_frame_file(frame)
          return vim.fn.expand(
            ("~/ghq/github.com/Rtosshy/dotfiles/assets/yoshitv-yoshi-frames/yoshi-%02d.png"):format(frame - 1)
          )
        end

        local function yoshi_delete_sequence()
          local chunks = {}
          for frame = 1, yoshi_frame_count do
            chunks[#chunks + 1] = ("\27_Ga=d,d=i,i=%d,q=2\27\\"):format(yoshi_image_id_base + frame)
          end
          return table.concat(chunks)
        end

        local function yoshi_image_sequence(frame)
          local file = yoshi_frame_file(frame)
          local fd = io.open(file, "rb")

          if not fd then
            vim.notify("Yoshi frame was not found: " .. file, vim.log.levels.ERROR)
            return nil
          end

          fd:close()

          local image_id = yoshi_image_id_base + frame
          local image_size = yoshi_image_size()
          local image_col = math.max(0, math.floor((vim.o.columns - image_size.cols) / 2))

          return table.concat({
            "\27[s",
            ("\27[%d;%dH"):format(yoshi_image_row(), image_col + 1),
            yoshi_delete_sequence(),
            ("\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;"):format(image_id, image_size.cols, image_size.rows),
            vim.base64.encode(file),
            "\27\\",
            "\27[u",
          })
        end

        local function send_to_terminal(sequence)
          if vim.api.nvim_ui_send then
            vim.api.nvim_ui_send(sequence)
          else
            io.stdout:write(sequence)
          end
        end

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

            if vim.bo.filetype ~= "alpha" then
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

        dashboard.section.buttons.val = {
          dashboard.button("e", "\u{f07c}  Open directory", "<cmd>lua require('oil').toggle_float()<cr>"),
          dashboard.button("f", "\u{f002}  Find file", "<cmd>lua require('telescope.builtin').find_files()<cr>"),
          dashboard.button("r", "\u{f1da}  Recent files", "<cmd>lua require('telescope.builtin').oldfiles()<cr>"),
          dashboard.button("g", "\u{f419}  LazyGit", "<cmd>LazyGit<cr>"),
          dashboard.button("q", "\u{f011}  Quit", "<cmd>qa<cr>"),
        }

        dashboard.section.header.val = yoshi_vim_logo
        dashboard.section.header.opts = {
          hl = "Type",
          position = "center",
        }

        dashboard.config.layout = {
          { type = "padding", val = top_padding },
          dashboard.section.header,
          { type = "padding", val = 18 },
          dashboard.section.buttons,
        }

        alpha.setup(dashboard.config)

        local yoshi_group = vim.api.nvim_create_augroup("AlphaYoshiImage", { clear = true })
        vim.api.nvim_create_autocmd("User", {
          group = yoshi_group,
          pattern = "AlphaReady",
          callback = function()
            vim.defer_fn(start_yoshi_animation, 80)
          end,
        })
        vim.api.nvim_create_autocmd("BufEnter", {
          group = yoshi_group,
          callback = function()
            if vim.bo.filetype ~= "alpha" then
              return
            end

            vim.defer_fn(function()
              if vim.bo.filetype == "alpha" then
                start_yoshi_animation()
              end
            end, 80)
          end,
        })
        vim.api.nvim_create_autocmd("BufLeave", {
          group = yoshi_group,
          callback = function()
            if yoshi_animation_running then
              yoshi_animation_running = false
              yoshi_animation_generation = yoshi_animation_generation + 1
              clear_yoshi_image()
            end
          end,
        })
        vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
          group = yoshi_group,
          callback = function()
            if vim.bo.filetype == "alpha" then
              pcall(alpha.redraw)
              vim.defer_fn(start_yoshi_animation, 160)
            end
          end,
        })
    '';
  };
}
