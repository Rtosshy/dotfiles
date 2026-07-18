---
title: WezTerm上でkitten TUIのキーが効かない(kitty keyboard protocolがデフォルト無効)
id: wezterm-kitty-keyboard-0001
type: research
category: wezterm
status: active
created: 2026-07-13
valid_as_of: 2026-07-13
owner: "@Rtosshy"
tags: [wezterm, kitty, kitten, keyboard-protocol, terminfo, debugging]
---

<!-- 出力先: docs/wezterm/research/kitten-tui-keys-require-kitty-keyboard-protocol.md -->

> ✅ **ACTIVE（有効・2026-07-13 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# WezTerm上でkitten TUIのキーが効かない(kitty keyboard protocolがデフォルト無効)

## 問い / Question

WezTerm上で `kitten themes` を開くと、`j`/`k` の上下移動・`q` の終了・`/` の検索が一切効かない。`TERM=xterm-kitty kitten themes` としても変化なし。kitty上では全く問題ないのに、なぜWezTermだけキー入力が死ぬのか。

## 結論 / Findings

**WezTermは kitty keyboard protocol への対応がオプトインで、`enable_kitty_keyboard` のデフォルトが `false` のため**(wezterm 20260117-154428 時点)。

- kittenのTUI(`kitten themes` 等)は起動時にエスケープシーケンスで kitty keyboard protocol をターミナルに要求し、以降は**キーを専用のキーイベント形式(CSI u)で受け取る前提**で動く。
- WezTermはデフォルトではこの要求を無視するため、`j` や `q` はただのテキストバイトとして送られ、kitten側のキーイベントハンドラには届かない。結果として全キーが無反応になる。
- 修正は `wezterm.lua` に1行:

  ```lua
  config.enable_kitty_keyboard = true
  ```

**`TERM=xterm-kitty` が効かなかった理由**: terminfoは「アプリがターミナルの能力を*引く*ための静的データベース」であって、kitty keyboard protocol は**実行時にエスケープシーケンスで動的にネゴシエートされる**。TERMを変えてもWezTermがプロトコル要求に応答するようにはならない。むしろWezTerm内で `TERM=xterm-kitty` を名乗ると別の不整合(kitty固有のterminfoエントリを引いてしまう)を招くので設定しないこと。

## 試したこと・観測 / What was tried

- kitty上では `kitten themes` のキー操作は全て正常 → kitten側ではなくターミナル側の差異と切り分け。
- `TERM=xterm-kitty kitten themes` → 効果なし(上記の通り、terminfoとプロトコルネゴシエーションは別レイヤー)。
- [wezterm.lua](../../../modules/shared/wezterm/config/wezterm.lua) を確認 → `enable_kitty_keyboard` の指定なし(= デフォルト `false` が適用されていた)。
- WezTerm公式ドキュメントでデフォルト値 `false` を確認。

## 根拠・出典 / Evidence

- WezTerm公式: [enable_kitty_keyboard](https://wezterm.org/config/lua/config/enable_kitty_keyboard.html) — デフォルト `false`、有効時のみ「kitty keyboard protocol escape sequences that modify the keyboard encoding」を尊重する
- kitty公式: [Comprehensive keyboard handling protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) — プロトコルの仕様。実行時のCSIシーケンスによるネゴシエーションであることが分かる
- 検証方法(kitty FAQ推奨): ターミナル内で `kitten show-key -m kitty` を実行し、キーイベントが表示されればプロトコルが機能している

## 考慮・トレードオフ / Considerations

- **WezTermのこのプロトコル実装には既知のバグ報告がある。** 有効化は無条件に安全ではない:
  - [wezterm#5167](https://github.com/wezterm/wezterm/issues/5167) — AltGr/デッドキーが効かなくなる
  - [wezterm#4785](https://github.com/wezterm/wezterm/issues/4785) — kittyと異なるキーコードを送ることがある
  - 一部TUIアプリでEscキーが壊れる報告もある
  - このため [wezterm.lua](../../../modules/shared/wezterm/config/wezterm.lua) には**警告コメント付き**で有効化した。今後、他のTUIアプリ(nvim等)でキー入力に違和感が出たら、まずこのオプションを疑って一時的に無効化して切り分けること。
- `~/.config/wezterm/` はhome-managerによるnix storeへのsymlinkなので、**リポジトリのluaを編集しただけでは反映されない。rebuild(switch)が必要**。
- プロトコルのネゴシエーションはkitten起動時に行われるため、設定反映後に**kitten自体の再起動**も必要(WezTermの `automatically_reload_config` だけでは既に起動中のkittenは直らない)。

## 次アクション / Open questions

- rebuild後、WezTerm内で `kitten show-key -m kitty` → `kitten themes` の順に動作確認する。
- `enable_kitty_keyboard = true` による他TUIアプリへの退行(AltGr・Esc周り)を日常使用で監視する。問題が出た場合はこの記録から decision(有効化を維持するか否か)に昇格させる。

## 関連

- [wezterm.lua](../../../modules/shared/wezterm/config/wezterm.lua) — 実際に修正した設定ファイル(警告コメント付き)

<!--
ある時点のスナップショット。後で状況が変わってもこの記録は編集しない。
詳細は reference/knowledge-types.md「昇格の連鎖」。
-->
