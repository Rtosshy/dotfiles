{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      hlsearch = false;
      number = true;
      relativenumber = true;
      mouse = "a";
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      backup = false;
      writebackup = false;
      termguicolors = true;
      whichwrap = "bs<>[]hl";
      wrap = false;
      linebreak = true;
      scrolloff = 4;
      sidescrolloff = 8;
      numberwidth = 4;
      shiftwidth = 4;
      tabstop = 4;
      softtabstop = 4;
      expandtab = true;
      cursorline = false;
      splitbelow = true;
      splitright = true;
      swapfile = false;
      smartindent = true;
      showmode = false;
      showtabline = 2;
      backspace = "indent,eol,start";
      pumheight = 10;
      conceallevel = 0;
      fileencoding = "utf-8";
      cmdheight = 1;
      autoindent = true;
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
    };

    extraConfigLuaPre = ''
      vim.opt.shortmess:append("c")
      vim.opt.iskeyword:append("-")
      vim.opt.formatoptions:remove({ "c", "r", "o" })
      vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")
      vim.cmd([[let &t_Cs = "\e[4:3m"]])
      vim.cmd([[let &t_Ce = "\e[4:0m"]])
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
    '';

    colorschemes.tokyonight.enable = true;

    autoCmd = [
      {
        event = "InsertLeave";
        pattern = "*";
        command = "set nopaste";
      }
      {
        event = "FileType";
        pattern = [
          "json"
          "jsonc"
          "jsonl"
        ];
        callback.__raw = ''
          function()
            vim.wo.spell = false
            vim.wo.conceallevel = 0
          end
        '';
      }
      {
        event = "FileType";
        pattern = [
          "c"
          "cpp"
        ];
        callback.__raw = ''
          function()
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
          end
        '';
      }
      {
        event = "LspAttach";
        callback.__raw = ''
          function(args)
            local opts = { buffer = args.buf, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          end
        '';
      }
      {
        event = "FileType";
        callback.__raw = ''
          function() pcall(vim.treesitter.start) end
        '';
      }
    ];

    keymaps =
      let
        opts = {
          noremap = true;
          silent = true;
        };
      in
      [
        {
          mode = [
            "n"
            "v"
          ];
          key = "<Space>";
          action = "<Nop>";
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-s>";
          action = "<cmd> w <CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<leader>sn";
          action = "<cmd>noautocmd w <CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<C-q>";
          action = "<cmd> q <CR>";
          options = opts;
        }

        {
          mode = "n";
          key = "x";
          action = "\"_x";
          options = opts;
        }

        {
          mode = [
            "n"
            "i"
            "v"
            "s"
          ];
          key = "<ScrollWheelUp>";
          action = "<Nop>";
          options = opts;
        }
        {
          mode = [
            "n"
            "i"
            "v"
            "s"
          ];
          key = "<ScrollWheelDown>";
          action = "<Nop>";
          options = opts;
        }
        {
          mode = [
            "n"
            "i"
            "v"
            "s"
          ];
          key = "<ScrollWheelLeft>";
          action = "<Nop>";
          options = opts;
        }
        {
          mode = [
            "n"
            "i"
            "v"
            "s"
          ];
          key = "<ScrollWheelRight>";
          action = "<Nop>";
          options = opts;
        }

        {
          mode = "n";
          key = "<C-d>";
          action = "<C-d>zz";
          options = opts;
        }
        {
          mode = "n";
          key = "<C-u>";
          action = "<C-u>zz";
          options = opts;
        }

        {
          mode = "n";
          key = "n";
          action = "nzzzv";
          options = opts;
        }
        {
          mode = "n";
          key = "N";
          action = "Nzzzv";
          options = opts;
        }

        {
          mode = "n";
          key = "<Up>";
          action = ":resize -2<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<Down>";
          action = ":resize +2<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<Left>";
          action = ":vertical resize -2<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<Right>";
          action = ":vertical resize +2<CR>";
          options = opts;
        }

        {
          mode = "n";
          key = "]b";
          action = "<cmd>bnext<cr>";
          options = opts;
        }
        {
          mode = "n";
          key = "[b";
          action = "<cmd>bprevious<cr>";
          options = opts;
        }
        {
          mode = "n";
          key = "<leader>bx";
          action = ":bdelete<CR>";
          options = opts;
        }

        {
          mode = "n";
          key = "<leader>wsv";
          action = "<C-w>v";
          options = opts;
        }
        {
          mode = "n";
          key = "<leader>wsh";
          action = "<C-w>s";
          options = opts;
        }
        {
          mode = "n";
          key = "<leader>wse";
          action = "<C-w>=";
          options = opts;
        }
        {
          mode = "n";
          key = "<leader>wx";
          action = ":close<CR>";
          options = opts;
        }

        {
          mode = "n";
          key = "<C-k>";
          action = ":wincmd k<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<C-j>";
          action = ":wincmd j<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<C-h>";
          action = ":wincmd h<CR>";
          options = opts;
        }
        {
          mode = "n";
          key = "<C-l>";
          action = ":wincmd l<CR>";
          options = opts;
        }

        {
          mode = "n";
          key = "<leader>lw";
          action = "<cmd>set wrap!<CR>";
          options = opts;
        }

        {
          mode = "v";
          key = "<";
          action = "<gv";
          options = opts;
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options = opts;
        }
        {
          mode = "v";
          key = "p";
          action = "\"_dP";
          options = opts;
        }

        {
          mode = "n";
          key = "[d";
          action.__raw = ''
            function()
              vim.diagnostic.jump({ count = -1, float = true })
            end
          '';
          options.desc = "Go to previous diagnostic message";
        }
        {
          mode = "n";
          key = "]d";
          action.__raw = ''
            function()
              vim.diagnostic.jump({ count = 1, float = true })
            end
          '';
          options.desc = "Go to next diagnostic message";
        }
        {
          mode = "n";
          key = "<leader>d";
          action.__raw = "vim.diagnostic.open_float";
          options.desc = "Open floating diagnostic message";
        }
        {
          mode = "n";
          key = "<leader>q";
          action.__raw = "vim.diagnostic.setloclist";
          options.desc = "Open diagnostics list";
        }

        # im-select: switch IME to ABC on Esc
        {
          mode = "n";
          key = "<Esc>";
          action.__raw = ''
            function()
              vim.system({ "macism", "com.apple.keylayout.ABC" })
            end
          '';
        }

        # oil
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>lua require('oil').toggle_float()<CR>";
          options.silent = true;
        }

        # telescope
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options = {
            silent = true;
            desc = "Telescope find files";
          };
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options = {
            silent = true;
            desc = "Telescope live grep";
          };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options = {
            silent = true;
            desc = "Telescope buffers";
          };
        }
        {
          mode = "n";
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options = {
            silent = true;
            desc = "Telescope help tags";
          };
        }

        # devdocs
        {
          mode = "n";
          key = "<leader>ho";
          action = "<cmd>DevDocs get<cr>";
          options = {
            silent = true;
            desc = "Open DevDocs";
          };
        }
        {
          mode = "n";
          key = "<leader>hi";
          action = "<cmd>DevDocs install<cr>";
          options = {
            silent = true;
            desc = "Install DevDocs";
          };
        }
        {
          mode = "n";
          key = "<leader>hv";
          action.__raw = ''
            function()
              if not _G.setup_devdocs() then
                return
              end

              local devdocs = require("devdocs")
              local installed_docs = devdocs.GetInstalledDocs()
              vim.ui.select(installed_docs, {}, function(selected)
                if not selected then
                  return
                end

                local doc_dir = devdocs.GetDocDir(selected)
                require("telescope.builtin").find_files({ cwd = doc_dir })
              end)
            end
          '';
          options.desc = "View DevDocs";
        }
        {
          mode = "n";
          key = "<leader>hd";
          action = "<cmd>DevDocs delete<cr>";
          options = {
            silent = true;
            desc = "Delete DevDocs";
          };
        }

        # lazygit
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<CR>";
          options = {
            silent = true;
            desc = "LazyGit";
          };
        }

        # trouble
        {
          mode = "n";
          key = "<leader>xx";
          action = "<cmd>Trouble diagnostics toggle<CR>";
          options = {
            silent = true;
            desc = "Diagnostics (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xX";
          action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
          options = {
            silent = true;
            desc = "Buffer Diagnostics (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>cs";
          action = "<cmd>Trouble symbols toggle focus=false<CR>";
          options = {
            silent = true;
            desc = "Symbols (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>cl";
          action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
          options = {
            silent = true;
            desc = "LSP Definitions / references / ... (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xL";
          action = "<cmd>Trouble loclist toggle<CR>";
          options = {
            silent = true;
            desc = "Location List (Trouble)";
          };
        }
        {
          mode = "n";
          key = "<leader>xQ";
          action = "<cmd>Trouble qflist toggle<CR>";
          options = {
            silent = true;
            desc = "Quickfix List (Trouble)";
          };
        }

        # conform: manual format
        {
          mode = "n";
          key = "gq";
          action.__raw = ''
            function()
              require("conform").format({ async = true })
            end
          '';
          options.desc = "Format";
        }
      ];

    plugins = {
      web-devicons.enable = true;

      mini = {
        enable = true;
        modules.icons = { };
      };

      bufferline.enable = true;

      lualine = {
        enable = true;
        settings.options.theme = "tokyonight";
      };

      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>b";
            group = "buffer";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "diagnostics";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "help";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "line";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "save";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "window";
          }
          {
            __unkeyed-1 = "<leader>ws";
            group = "split";
          }
        ];
      };

      smear-cursor.enable = true;
      snacks.enable = true;
      lazygit.enable = true;
      trouble.enable = true;

      oil = {
        enable = true;
        settings = {
          view_options.show_hidden = true;
          keymaps.__raw = ''
            {
              ["g?"] = { "actions.show_help", mode = "n" },
              ["<CR>"] = "actions.select",
              ["<C-s>"] = { "actions.select", opts = { vertical = true } },
              ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
              ["<C-t>"] = { "actions.select", opts = { tab = true } },
              ["<C-p>"] = "actions.preview",
              ["<C-c>"] = { "actions.close", mode = "n" },
              ["<C-l>"] = "actions.refresh",
              ["-"] = { "actions.parent", mode = "n" },
              ["_"] = { "actions.open_cwd", mode = "n" },
              ["`"] = { "actions.cd", mode = "n" },
              ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
              ["gs"] = { "actions.change_sort", mode = "n" },
              ["gx"] = "actions.open_external",
              ["g."] = { "actions.toggle_hidden", mode = "n" },
              ["g\\"] = { "actions.toggle_trash", mode = "n" },
            }
          '';
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      treesitter = {
        enable = true;
        settings.ensure_installed = [
          "lua"
          "go"
          "rust"
          "yaml"
          "bash"
          "fish"
          "c"
          "cpp"
          "nix"
        ];
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            go = [ "gofmt" ];
            cpp = [ "clang-format" ];
            c = [ "clang-format" ];
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          lua_ls = {
            enable = true;
            settings.Lua.diagnostics.globals = [ "vim" ];
          };
          gopls.enable = true;
        };
      };
    };

    # alpha-nvim is loaded manually so we can attach the Yoshi image animation.
    # im-select.nvim is loaded manually because nixvim's wrapper diverges from
    # the upstream defaults around macOS IME switching.
    extraPlugins = with pkgs.vimPlugins; [
      alpha-nvim
      devdocs-nvim
      im-select-nvim
    ];

    extraConfigLuaPost = ''
      if not vim.g.vscode then
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
          dashboard.button("e", "\u{f07c}  Open directory", "<cmd>Oil<cr>"),
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
      end

      require("im_select").setup({
        default_command = "macism",
        set_previous_events = {},
      })

      local devdocs_configured = false
      function _G.setup_devdocs()
        if devdocs_configured then
          return true
        end

        vim.fn.mkdir(vim.fn.stdpath("data") .. "/devdocs", "p")
        pcall(vim.api.nvim_del_user_command, "DevDocs")

        local ok, devdocs = pcall(require, "devdocs")
        if not ok then
          vim.notify("Failed to load devdocs.nvim", vim.log.levels.ERROR)
          return false
        end

        devdocs.setup({
          ensure_installed = {
            "go",
            "html",
            "http",
            "lua~5.1",
          },
        })
        devdocs_configured = true
        return true
      end

      vim.api.nvim_create_user_command("DevDocs", function(opts)
        if _G.setup_devdocs() then
          vim.cmd.DevDocs(opts.args)
        end
      end, { nargs = "*" })

      if vim.g.vscode then
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<leader>e", "<Cmd>call VSCodeNotify('workbench.view.explorer')<CR>", opts)
        vim.keymap.set("n", "<leader>c", "<Cmd>call VSCodeNotify('workbench.action.chat.open')<CR>", opts)
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        severity_sort = true,
        float = { source = true },
      })
    '';
  };
}
