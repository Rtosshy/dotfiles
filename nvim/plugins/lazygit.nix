{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
        options = {
          silent = true;
          desc = "LazyGit";
        };
      }
    ];

    plugins.lazygit.enable = true;
  };
}
