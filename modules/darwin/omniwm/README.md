# OmniWM

OmniWM設定を **ベース + 差分の2層** で管理する。`$HOME/.config/omniwm/settings.toml` はビルド時の生成物であり、リポジトリには持たない。

| ファイル | 誰が書くか | 役割 |
| --- | --- | --- |
| `base.toml` | **OmniWMが生成。人は編集しない** | アプリが要求する完全形。約980行 |
| `overrides.nix` | 人 | 意図した設定だけ。スカラー8件 + hotkey 67件 |
| `merge.py` | 人(滅多に触らない) | baseに値を差し込む。検証も担う |
| `default.nix` | 人 | 生成物を実ファイルとして配置 |

## 2層にする理由

OmniWM 0.6.3以降、`settings.toml` は完全な現行スキーマでなければ**ファイル全体が無効**になる。必須キーが1つ欠けても、hotkey配列が全assignable actionを過不足なく含まなくても、アプリは preserve-and-reset を実行する。部分設定という概念が存在しない。

一方で意図した設定は全体の1割以下しかない。残りはアプリが要求する定型で、アップグレードのたびに壊れる部分でもある。

2層にすると、**overridesのキーがbaseに無いときビルドが失敗する**。OmniWMがキーを改名・削除した場合、設定が静かに失われる代わりに `home-manager switch` がその場で落ちる。

```
$ nix build ...
merge.py: error: settings override niri.maxVisibleColumns matched 0 lines; expected exactly one
```

判断の経緯は [ADR](../../../docs/omniwm/decision/settings-toml-sync-model.md)、そうなった原因は [postmortem](../../../docs/omniwm/postmortem/settings-toml-reset-on-0-6-4-upgrade.md) を参照。

### baseを再シリアライズしない理由

`merge.py` はTOMLをパースして書き戻さず、**行単位で値だけを差し替える**。`borders.width = 1.0`(float)と `mouseWarp.margin = 1`(integer)の区別がNix → JSON → TOMLの経路で潰れうるためで、0.6.3以降は型不正もファイル全体を無効化する。触れていない行はバイト単位で保たれる。

## 設定を変えるとき

`overrides.nix` だけを編集する。`base.toml` は触らない。

## OmniWMをアップグレードしたとき

`base.toml` を取り直す。**必ず「設定ファイルが無い状態でOmniWMを起動して吐かせたもの」を使うこと。** 稼働中インスタンスからコピーするとGUI変更が混ざり、意図が2層に散って2層化の意味が失われる。

```sh
osascript -e 'quit app "OmniWM"'
mv ~/.config/omniwm/settings.toml /tmp/omniwm-settings.bak
open -a OmniWM && sleep 5
osascript -e 'quit app "OmniWM"'
cp ~/.config/omniwm/settings.toml modules/darwin/omniwm/base.toml
```

その後 `nix build` する。落ちたら、落ちたキーだけを調べてupstreamのリリースノートで改名先を確認し、`overrides.nix` を直す。

## 反映手順

OmniWMは起動中のメモリ上の設定を `settings.toml` に書き戻すことがある。設定変更を確実に反映したい場合は、先にOmniWMを終了してから switch する。

```sh
osascript -e 'quit app "OmniWM"'
home-manager switch --flake ~/ghq/github.com/Rtosshy/dotfiles#tosshy@MacBook-V3
open -a OmniWM
```

反映後はIPCと主要設定を確認する。`ipcEnabled` は初期値が `false` なので、**`ping` が通ること自体が「生成物が読まれた」証明**になる。

```sh
/Applications/OmniWM.app/Contents/MacOS/omniwmctl ping
ls ~/.config/omniwm/settings.toml.corrupt*   # 増えていないこと
rg -n 'ipcEnabled|followsWindowToMonitor|reserveLayoutSpace' ~/.config/omniwm/settings.toml
```

## 2026-06-14の調査メモ

<!-- 歴史的文脈。当時のOmniWM 0.4.9.7に対する観測であり、現在の構成の説明ではない -->

- OmniWM 0.4.9.7で、未受理のhotkey IDを含む設定を読み込ませると、アプリ起動後に `settings.toml` が古い値へ戻り、`ipcEnabled = false` になる挙動を確認した。
- `omniwmctl command switch-workspace anywhere <number>` は存在するが、`settings.toml` のhotkey IDとして `switchWorkspaceAnywhere.N` は受理されなかった。hotkeyでは `switchWorkspace.N` を使う。
- 2枚モニタ環境で、`omniwmctl query workspace-bar --format json` が外部ディスプレイのバーを `isVisible = true` と返しても、見た目では隠れることがある。`workspaceBar.reserveLayoutSpace = true` はその回避策として残している。
- ワークスペース切り替え後にフォーカスが分かりにくくなる対策として、`focus.followsWindowToMonitor = true` と `focus.moveMouseToFocusedWindow = true` を有効にしている。
- 関連upstream issue: [#371](https://github.com/BarutSRB/Hiro/issues/371) Separate runtime state from settings.toml, [#324](https://github.com/BarutSRB/Hiro/issues/324) Runtime state stored in settings.toml, [#278](https://github.com/BarutSRB/Hiro/issues/278) settings.toml holds ephemeral state data, [#410](https://github.com/BarutSRB/Hiro/issues/410) Settings save drops unknown TOML keys, [#260](https://github.com/BarutSRB/Hiro/issues/260) update settings on file save doesn't work.
