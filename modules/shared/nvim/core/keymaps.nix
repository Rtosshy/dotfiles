{
  keymaps =
    let
      opts = {
        noremap = true;
        silent = true;
      };

      descriptions = {
        "<C-s>" = "Save file";
        "<leader>sn" = "Save file without autocommands";
        "<C-q>" = "Quit";
        "x" = "Delete character without yank";
        "<C-d>" = "Scroll down and center";
        "<C-u>" = "Scroll up and center";
        "n" = "Next search result and center";
        "N" = "Previous search result and center";
        "<Up>" = "Decrease window height";
        "<Down>" = "Increase window height";
        "<Left>" = "Decrease window width";
        "<Right>" = "Increase window width";
        "]b" = "Next buffer";
        "[b" = "Previous buffer";
        "<leader>bo" = "Delete other buffers";
        "<leader>bx" = "Delete buffer";
        "<leader>w\\" = "Split window vertically";
        "<leader>w-" = "Split window horizontally";
        "<leader>w=" = "Equalize window sizes";
        "<leader>wo" = "Close other windows";
        "<leader>wx" = "Close window";
        "<C-k>" = "Focus window above";
        "<C-j>" = "Focus window below";
        "<C-h>" = "Focus window left";
        "<C-l>" = "Focus window right";
        "<leader>lw" = "Toggle line wrap";
        "<" = "Indent left and reselect";
        ">" = "Indent right and reselect";
        "p" = "Paste without yanking replaced text";
      };

      withDesc =
        keymap:
        keymap
        // {
          options =
            (keymap.options or opts)
            // (
              if builtins.hasAttr keymap.key descriptions then
                { desc = builtins.getAttr keymap.key descriptions; }
              else
                { }
            );
        };
    in
    map withDesc [
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
        key = "<leader>bo";
        action = "<cmd>BufferOnly<CR>";
        options = opts;
      }

      {
        mode = "n";
        key = "<leader>w\\";
        action = "<C-w>v";
        options = opts;
      }
      {
        mode = "n";
        key = "<leader>w-";
        action = "<C-w>s";
        options = opts;
      }
      {
        mode = "n";
        key = "<leader>w=";
        action = "<C-w>=";
        options = opts;
      }
      {
        mode = "n";
        key = "<leader>wo";
        action = "<cmd>only<CR>";
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
    ];
}
