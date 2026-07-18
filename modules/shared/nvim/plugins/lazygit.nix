{
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

  plugins.lazygit = {
    enable = true;

    # プラグインが提供する全コマンドを cmd トリガーに登録し、
    # ロード前に :LazyGit* を打っても動くようにする。
    lazyLoad.settings.cmd = [
      "LazyGit"
      "LazyGitLog"
      "LazyGitCurrentFile"
      "LazyGitFilter"
      "LazyGitFilterCurrentFile"
      "LazyGitConfig"
    ];
  };
}
