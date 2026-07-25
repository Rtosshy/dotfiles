{
  plugins.live-share = {
    enable = true;
    settings = {
      username = "tosshy";
      port = 80;
      transport = "ws";
    };

    # セッション開始コマンドでのみロードする。開始後は残りの
    # :LiveShare* コマンドもプラグイン側で登録される。
    lazyLoad.settings.cmd = [
      "LiveShareHostStart"
      "LiveShareJoin"
      "LiveShareServer"
    ];
  };
}
