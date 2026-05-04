{
  programs.nixvim = {
    keymaps = [
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
    ];

    plugins.telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };
  };
}
