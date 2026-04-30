{ inputs, pkgs, ... }: {
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
      mouse = "v";
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
      completeopt = [ "menu" "menuone" "noselect" ];
    };

    extraConfigLuaPre = ''
      vim.opt.shortmess:append("c")
      vim.opt.iskeyword:append("-")
      vim.opt.formatoptions:remove({ "c", "r", "o" })
      vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")
      vim.cmd([[let &t_Cs = "\e[4:3m"]])
      vim.cmd([[let &t_Ce = "\e[4:0m"]])
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
        pattern = [ "json" "jsonc" "jsonl" ];
        callback.__raw = ''
          function()
            vim.wo.spell = false
            vim.wo.conceallevel = 0
          end
        '';
      }
      {
        event = "FileType";
        pattern = [ "c" "cpp" ];
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
        opts = { noremap = true; silent = true; };
      in
      [
        { mode = [ "n" "v" ]; key = "<Space>"; action = "<Nop>"; options.silent = true; }

        { mode = "n"; key = "<C-s>"; action = "<cmd> w <CR>"; options = opts; }
        { mode = "n"; key = "<leader>sn"; action = "<cmd>noautocmd w <CR>"; options = opts; }
        { mode = "n"; key = "<C-q>"; action = "<cmd> q <CR>"; options = opts; }

        { mode = "n"; key = "x"; action = "\"_x"; options = opts; }

        { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; options = opts; }
        { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; options = opts; }

        { mode = "n"; key = "n"; action = "nzzzv"; options = opts; }
        { mode = "n"; key = "N"; action = "Nzzzv"; options = opts; }

        { mode = "n"; key = "<Up>"; action = ":resize -2<CR>"; options = opts; }
        { mode = "n"; key = "<Down>"; action = ":resize +2<CR>"; options = opts; }
        { mode = "n"; key = "<Left>"; action = ":vertical resize -2<CR>"; options = opts; }
        { mode = "n"; key = "<Right>"; action = ":vertical resize +2<CR>"; options = opts; }

        { mode = "n"; key = "]b"; action = "<cmd>bnext<cr>"; options = opts; }
        { mode = "n"; key = "[b"; action = "<cmd>bprevious<cr>"; options = opts; }
        { mode = "n"; key = "<leader>bx"; action = ":bdelete<CR>"; options = opts; }

        { mode = "n"; key = "<leader>wsv"; action = "<C-w>v"; options = opts; }
        { mode = "n"; key = "<leader>wsh"; action = "<C-w>s"; options = opts; }
        { mode = "n"; key = "<leader>wse"; action = "<C-w>="; options = opts; }
        { mode = "n"; key = "<leader>wx"; action = ":close<CR>"; options = opts; }

        { mode = "n"; key = "<C-k>"; action = ":wincmd k<CR>"; options = opts; }
        { mode = "n"; key = "<C-j>"; action = ":wincmd j<CR>"; options = opts; }
        { mode = "n"; key = "<C-h>"; action = ":wincmd h<CR>"; options = opts; }
        { mode = "n"; key = "<C-l>"; action = ":wincmd l<CR>"; options = opts; }

        { mode = "n"; key = "<leader>lw"; action = "<cmd>set wrap!<CR>"; options = opts; }

        { mode = "v"; key = "<"; action = "<gv"; options = opts; }
        { mode = "v"; key = ">"; action = ">gv"; options = opts; }
        { mode = "v"; key = "p"; action = "\"_dP"; options = opts; }

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
          options = { silent = true; desc = "Telescope find files"; };
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options = { silent = true; desc = "Telescope live grep"; };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options = { silent = true; desc = "Telescope buffers"; };
        }
        {
          mode = "n";
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options = { silent = true; desc = "Telescope help tags"; };
        }

        # lazygit
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<CR>";
          options = { silent = true; desc = "LazyGit"; };
        }

        # trouble
        {
          mode = "n";
          key = "<leader>xx";
          action = "<cmd>Trouble diagnostics toggle<CR>";
          options = { silent = true; desc = "Diagnostics (Trouble)"; };
        }
        {
          mode = "n";
          key = "<leader>xX";
          action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
          options = { silent = true; desc = "Buffer Diagnostics (Trouble)"; };
        }
        {
          mode = "n";
          key = "<leader>cs";
          action = "<cmd>Trouble symbols toggle focus=false<CR>";
          options = { silent = true; desc = "Symbols (Trouble)"; };
        }
        {
          mode = "n";
          key = "<leader>cl";
          action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
          options = { silent = true; desc = "LSP Definitions / references / ... (Trouble)"; };
        }
        {
          mode = "n";
          key = "<leader>xL";
          action = "<cmd>Trouble loclist toggle<CR>";
          options = { silent = true; desc = "Location List (Trouble)"; };
        }
        {
          mode = "n";
          key = "<leader>xQ";
          action = "<cmd>Trouble qflist toggle<CR>";
          options = { silent = true; desc = "Quickfix List (Trouble)"; };
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
          { __unkeyed-1 = "<leader>b"; group = "buffer"; }
          { __unkeyed-1 = "<leader>d"; group = "diagnostics"; }
          { __unkeyed-1 = "<leader>f"; group = "find"; }
          { __unkeyed-1 = "<leader>g"; group = "git"; }
          { __unkeyed-1 = "<leader>l"; group = "line"; }
          { __unkeyed-1 = "<leader>s"; group = "save"; }
          { __unkeyed-1 = "<leader>w"; group = "window"; }
          { __unkeyed-1 = "<leader>ws"; group = "split"; }
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

    # alpha-nvim is loaded manually so we can attach the yoshi header.
    # im-select.nvim is loaded manually because nixvim's wrapper diverges from
    # the upstream defaults around macOS IME switching.
    extraPlugins = with pkgs.vimPlugins; [
      alpha-nvim
      im-select-nvim
    ];

    extraFiles."lua/yoshi_header2.lua".source = ./yoshi_header2.lua;

    extraConfigLuaPost = ''
      do
        local ok, yoshi = pcall(require, "yoshi_header2")
        if ok then
          yoshi.setup_highlights()
          local dashboard = require("alpha.themes.dashboard")
          dashboard.section.header.val = yoshi.header
          dashboard.section.header.opts = { hl = yoshi.hl, position = "center" }
          require("alpha").setup(dashboard.config)
        end
      end

      require("im_select").setup({
        default_command = "macism",
        set_default_events = { "VimEnter", "InsertLeave", "CmdlineLeave" },
        set_previous_events = {},
      })

      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        severity_sort = true,
        float = { source = true },
      })
    '';
  };
}
