{
  programs.nixvim.keymaps =
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
    ];
}
