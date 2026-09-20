# OmniWM

OmniWM の導入と設定を [mst-mkt/omniwm.nix](https://github.com/mst-mkt/omniwm.nix) に委ねる。このディレクトリが持つのは **意図した設定だけ**(`default.nix` 1枚・スカラー8件 + hotkey 67件)。

| 何を | 誰が |
| --- | --- |
| OmniWM 本体 | flake の `packages.omniwm`(`fetchurl` で upstream のリリース zip)。バージョンは `flake.lock` に固定 |
| `settings.toml` の完全形 | flake の `settings-defaults.toml`。upstream ソースからの codegen で、CI がバージョン bump と同時に再生成 |
| 意図した設定 | `default.nix` の `programs.omniwm.settings` |
| 起動 | flake のモジュールが張る launchd agent(`org.nix-community.home.omniwm`) |

`$HOME/.config/omniwm/settings.toml` は activation 時の生成物であり、リポジトリには持たない。

## 仕組み

OmniWM は**完全な現行スキーマでない `settings.toml` をファイルごと破棄**する。必須キーが1つ欠けても、hotkey 配列が全 assignable action を過不足なく含まなくても、preserve-and-reset を実行する。部分設定という概念が無い。

flake のモジュールはこれを、`settings` をパッケージ版の defaults へ deep merge することで吸収する。ここに書くのは変更点だけでよい。

- **`hotkeys` は `id` 単位でマージ**される。リストごと置き換わらない。**未知の id は評価時に落ちる**ので、upstream が id を改名・削除すればその場で `nix build` が失敗する
- その他のリスト(`workspaces`, `appRules`, `monitor*Overrides`)は**丸ごと置き換え**になる
- スカラーのキー改名は検知できない。deep merge は未知のキーを黙って受け入れる

以前はこの完全形を `base.toml`(980行)として自前で抱え、`merge.py` で行単位に値を差し込んでいた。経緯は [ADR](../../../docs/omniwm/decision/adopt-omniwm-nix-flake.md)、その前段は [旧 ADR](../../../docs/omniwm/decision/settings-toml-sync-model.md) と [postmortem](../../../docs/omniwm/postmortem/settings-toml-reset-on-0-6-4-upgrade.md) を参照。

## 設定を変えるとき

`default.nix` の `programs.omniwm.settings` だけを編集する。キー名は [Settings Reference](https://omniwm.app/config/settings-reference/)、hotkey id と既定の binding は flake の [settings-defaults.toml](https://github.com/mst-mkt/omniwm.nix/blob/main/settings-defaults.toml) にある。

`inputs.omniwm.lib` に補助関数がある。`hotkeys`(`id = binding` のattrsetをリスト化)のほか、`colors.fromHex` / `appRule` / `workspaces` / `monitorOverride`。

## OmniWM をアップグレードするとき

```sh
nix flake update omniwm
nix build '.#homeConfigurations."tosshy@MacBook-V3".activationPackage'
```

hotkey id が改名・削除されていればここで落ち、エラーが不明な id を列挙する。落ちたら `default.nix` の該当 id を upstream のリリースノートで確認して直す。

`base.toml` を人手で取り直す手順は**不要になった**。defaults はパッケージのバージョンについてくる。

## 反映手順

OmniWM は起動中のメモリ上の設定を `settings.toml` に書き戻すことがある。確実に反映したい場合は先に終了してから switch する。

```sh
launchctl bootout gui/$(id -u)/org.nix-community.home.omniwm
home-manager switch --flake ~/ghq/github.com/Rtosshy/dotfiles#tosshy@MacBook-V3
```

activation が agent を張り直すので、手で起動する必要はない。直前の `settings.toml` は `settings.toml.bak` に残る。

反映後は IPC と主要設定を確認する。`ipcEnabled` は既定が `false` なので、**`ping` が通ること自体が「生成物が読まれた」証明**になる。

```sh
omniwmctl ping
ls ~/.config/omniwm/settings.toml.corrupt*   # 増えていないこと
rg -n 'ipcEnabled|followsWindowToMonitor|reserveLayoutSpace' ~/.config/omniwm/settings.toml
```

## macOS の権限

アクセシビリティ等の権限は nix store 上の実体パスに紐づく。バージョンを上げるとパスが変わるため、再付与を求められることがある。`システム設定 > プライバシーとセキュリティ` で古いエントリを消して付け直す。

## 2026-06-14 の調査メモ

<!-- 歴史的文脈。当時の OmniWM 0.4.9.7 に対する観測であり、現在の構成の説明ではない -->

- OmniWM 0.4.9.7 で、未受理の hotkey ID を含む設定を読み込ませると、アプリ起動後に `settings.toml` が古い値へ戻り、`ipcEnabled = false` になる挙動を確認した。
- `omniwmctl command switch-workspace anywhere <number>` は存在するが、`settings.toml` の hotkey ID として `switchWorkspaceAnywhere.N` は受理されなかった。hotkey では `switchWorkspace.N` を使う。
- 2枚モニタ環境で、`omniwmctl query workspace-bar --format json` が外部ディスプレイのバーを `isVisible = true` と返しても、見た目では隠れることがある。`workspaceBar.reserveLayoutSpace = true` はその回避策として残している。
- ワークスペース切り替え後にフォーカスが分かりにくくなる対策として、`focus.followsWindowToMonitor = true` を有効にしている。
- 関連 upstream issue: [#371](https://github.com/BarutSRB/Hiro/issues/371) Separate runtime state from settings.toml, [#324](https://github.com/BarutSRB/Hiro/issues/324) Runtime state stored in settings.toml, [#278](https://github.com/BarutSRB/Hiro/issues/278) settings.toml holds ephemeral state data, [#410](https://github.com/BarutSRB/Hiro/issues/410) Settings save drops unknown TOML keys, [#260](https://github.com/BarutSRB/Hiro/issues/260) update settings on file save doesn't work.
