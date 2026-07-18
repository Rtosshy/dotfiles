# OmniWM

このディレクトリでは `settings.toml` をOmniWM設定の正本として管理する。
`default.nix` はそのTOMLを `$HOME/.config/omniwm/settings.toml` に実ファイルとして配置するだけにしている。

## TOMLを正本にする理由

OmniWMは `settings.toml` を直接読み書きする。Nixのattrsetで再表現すると、OmniWM固有のhotkey IDやアプリが書き戻す順序との差分を追いづらい。

upstreamのissueやREADMEでも `settings.toml` 前提で説明されるため、このファイルをそのまま管理するほうが調査と反映が楽になる。

## 反映手順

OmniWMは起動中のメモリ上の設定を `settings.toml` に書き戻すことがある。設定変更を確実に反映したい場合は、先にOmniWMを終了してから `darwin-rebuild switch` する。

```sh
osascript -e 'quit app "OmniWM"'
home-manager switch --flake ~/ghq/github.com/Rtosshy/dotfiles#tosshy@MacBook-V3
open -a OmniWM
```

反映後はIPCと主要設定を確認する。

```sh
/Applications/OmniWM.app/Contents/MacOS/omniwmctl ping
rg -n 'ipcEnabled|followsWindowToMonitor|moveMouseToFocusedWindow|reserveLayoutSpace' ~/.config/omniwm/settings.toml
```

## 2026-06-14の調査メモ

- OmniWM 0.4.9.7で、未受理のhotkey IDを含む設定を読み込ませると、アプリ起動後に `settings.toml` が古い値へ戻り、`ipcEnabled = false` になる挙動を確認した。
- `omniwmctl command switch-workspace anywhere <number>` は存在するが、`settings.toml` のhotkey IDとして `switchWorkspaceAnywhere.N` は受理されなかった。hotkeyでは `switchWorkspace.N` を使う。
- 2枚モニタ環境で、`omniwmctl query workspace-bar --format json` が外部ディスプレイのバーを `isVisible = true` と返しても、見た目では隠れることがある。`workspaceBar.reserveLayoutSpace = true` はその回避策として残している。
- ワークスペース切り替え後にフォーカスが分かりにくくなる対策として、`focus.followsWindowToMonitor = true` と `focus.moveMouseToFocusedWindow = true` を有効にしている。
- 関連upstream issue: [#371](https://github.com/BarutSRB/Hiro/issues/371) Separate runtime state from settings.toml, [#324](https://github.com/BarutSRB/Hiro/issues/324) Runtime state stored in settings.toml, [#278](https://github.com/BarutSRB/Hiro/issues/278) settings.toml holds ephemeral state data, [#410](https://github.com/BarutSRB/Hiro/issues/410) Settings save drops unknown TOML keys, [#260](https://github.com/BarutSRB/Hiro/issues/260) update settings on file save doesn't work.
