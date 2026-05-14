{
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        # Git の差分状態ごとに sign column へ表示する記号。
        signs = {
          add = {
            text = "┃";
          };
          change = {
            text = "┃";
          };
          delete = {
            text = "_";
          };
          topdelete = {
            text = "‾";
          };
          changedelete = {
            text = "~";
          };
          untracked = {
            text = "┆";
          };
        };

        # git add 済みの差分に使う記号。
        signs_staged = {
          add = {
            text = "┃";
          };
          change = {
            text = "┃";
          };
          delete = {
            text = "_";
          };
          topdelete = {
            text = "‾";
          };
          changedelete = {
            text = "~";
          };
          untracked = {
            text = "┆";
          };
        };

        # staged の sign 表示を有効にする。
        signs_staged_enable = true;

        # sign column に差分記号を表示する。
        signcolumn = true;

        # 行番号や行全体のハイライトは控えめにして、記号だけ表示する。
        numhl = false;
        linehl = false;

        # 行内の単語単位の差分強調。
        word_diff = false;

        # .git ディレクトリの変更を監視し、rename などにも追従する。
        watch_gitdir = {
          follow_files = true;
        };

        # Git 管理下のバッファへ自動で gitsigns を attach する。
        auto_attach = true;

        # 未追跡ファイルには attach しない。
        attach_to_untracked = false;

        # カーソル行の blame を常時表示するかどうか。
        current_line_blame = false;

        # カーソル行 blame の表示方法。
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
          delay = 1000;
          ignore_whitespace = false;
          virt_text_priority = 100;
          use_focus = true;
        };

        # カーソル行 blame の表示フォーマット。
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>";

        # blame 表示の整形は gitsigns のデフォルトを使う。
        blame_formatter = null;

        # 他の sign と競合したときの表示優先度。
        sign_priority = 6;

        # 差分更新の debounce 時間。
        update_debounce = 100;

        # ステータスライン用の差分表示は gitsigns のデフォルトを使う。
        status_formatter = null;

        # 巨大ファイルでは gitsigns を無効化する。
        max_file_length = 40000;

        # hunk preview の floating window 設定。
        preview_config = {
          style = "minimal";
          relative = "cursor";
          row = 0;
          col = 1;
        };
      };
    };
  };
}
