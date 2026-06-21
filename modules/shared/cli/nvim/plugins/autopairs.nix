{
  plugins.nvim-autopairs = {
    enable = true;
    settings = {
      # treesitter の構文情報を使って対応する括弧の挿入を判定する。
      check_ts = true;

      # 言語ごとに treesitter のノード種別で挙動を調整する。
      ts_config = {
        lua = [ "string" ];
        javascript = [ "template_string" ];
      };

      # autopairs を無効化するファイルタイプ。
      disable_filetype = [ "TelescopePrompt" ];

      # 同じ行に既に開き括弧がある場合は閉じ括弧を補完しない。
      enable_check_bracket_line = true;

      # 閉じ括弧の直前で同じ閉じ括弧を打つと上書き移動する。
      enable_moveright = true;

      # <BS> で対になる括弧を同時に削除する。
      map_bs = true;

      # <C-h> で対になる括弧を同時に削除する。
      map_c_h = false;

      # <C-w> で対になる括弧を同時に削除する。
      map_c_w = false;
    };
  };
}
