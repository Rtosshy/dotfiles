{
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

    # lz.n による遅延ロード。<cmd>Telescope ...> 経由のキーマップは
    # cmd トリガーが拾うが、additional_args を渡す <leader>fl だけは
    # コマンド化できないため keys トリガーでロードを発火させる。
    lazyLoad.settings = {
      cmd = [ "Telescope" ];
      keys = [
        {
          __unkeyed-1 = "<leader>fl";
          __unkeyed-2 = "<cmd>lua require('telescope.builtin').live_grep({ additional_args = function() return { '--fixed-strings' } end })<CR>";
          mode = "n";
          silent = true;
          desc = "Telescope live grep literal";
        }
      ];
    };
  };
}
