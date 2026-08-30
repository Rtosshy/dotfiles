---
title: OmniWM 0.6.4 への自動アップグレードでsettings.tomlが全損し初期設定に戻った
id: omniwm-settings-schema-reset-0001
type: postmortem
category: omniwm
status: active
created: 2026-08-30
valid_as_of: 2026-08-30
owner: "@Rtosshy"
tags: [omniwm, settings-toml, schema-version, homebrew, nix-darwin, breaking-change, config-reset]
---

<!-- 出力先: docs/omniwm/postmortem/settings-toml-reset-on-0-6-4-upgrade.md -->

> ✅ **ACTIVE（有効・2026-08-30 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# OmniWM 0.6.4 への自動アップグレードでsettings.tomlが全損し初期設定に戻った

## 目次
- [要約](#要約)
- [事象と影響](#事象と影響)
- [時系列](#時系列)
- [根本原因](#根本原因)
- [なぜ自動マイグレーションが効かなかったか](#なぜ自動マイグレーションが効かなかったか)
- [失われた設定の全量](#失われた設定の全量)
- [0.5.4 → 0.6.4 の破壊的変更マップ](#054--064-の破壊的変更マップ)
- [再発条件](#再発条件)
- [学び](#学び)
- [次アクション](#次アクション)
- [根拠・出典](#根拠出典)
- [関連](#関連)

## 要約

`darwin-rebuild` 契機の Homebrew 自動アップグレードで OmniWM が **0.5.4 → 0.6.4** に一気に上がり、リポジトリ管理の `settings.toml` が**ファイル全体を無効と判定されて `settings.toml.corrupt.1` に退避**、live ファイルが**ビルトイン初期値で全置換**された。エラーダイアログも `darwin-rebuild` の失敗もなく、**静かに全設定が失われた**。

原因は OmniWM **0.6.3 で導入された「完全な現行スキーマ必須」検証**。欠損キーが1つでもあれば、あるいは hotkey 配列が全 assignable action を過不足なく含まなければ、ファイル全体が無効になる。dotfiles で `settings.toml` を管理する運用は、この変更以降**アップグレードごとの再同期が前提**になった。

## 事象と影響

- OmniWM が全設定を初期値で起動。カスタム hotkey バインド **67件すべて**が既定に戻り、`Left Option + hjkl` 系の操作が消滅。
- `general.ipcEnabled = false`(初期値)になり **`omniwmctl` が全滅**。`omniwmctl ping` は `NSPOSIXErrorDomain Code=2 "No such file or directory"`(IPCソケット不在)。[README](../../../modules/darwin/omniwm/README.md) の反映確認手順がそのまま通らない。
- borders/gaps/focus/workspaceBar の意図値も全て初期値化。
- **データ損失はない**。旧ファイルは `~/.config/omniwm/settings.toml.corrupt.1` にバイト単位で保全され、リポジトリにも同一内容が残っていた。

## 時系列

すべて 2026-08-30。

| 時刻 | 出来事 | 確認方法 |
| --- | --- | --- |
| 17:57 | Homebrew が `omniwm--0.6.4.zip` を取得(直前の取得は 0.5.4) | `~/Library/Caches/Homebrew/Cask/` の mtime |
| 18:00:57 | OmniWM 0.6.4 が起動 | `ps -eo pid,lstart,comm` |
| 18:00:58.397 | 旧 `settings.toml` を `settings.toml.corrupt.1` へ退避 | ファイル mtime |
| 18:00:58.398 | live `settings.toml` をビルトイン初期値で全置換 | ファイル mtime |

`~/Library/Caches/Homebrew/Cask/` に残るのは 0.4.9.7 / 0.5.0 / 0.5.2.1 / 0.5.4 / 0.6.4 のみで、**0.5.9〜0.6.3 を一度も経由していない**。段階的アップグレードなら 0.6.3 の破壊的変更に個別に気付けた可能性が高い。

なお `~/.local/state/omniwm/runtime-state.json` には `updaterSkippedReleaseTag: "0.5.10"` が記録されていた。**アプリ内で「このリリースをスキップ」しても Homebrew 経由のアップグレードは止まらない**。

## 根本原因

リポジトリの `settings.toml` が **0.5.8 以前のスキーマ**のまま、0.6.4 の厳格な検証にかけられた。

0.6.3 リリースノートより:

> Missing or decode-invalid required values no longer inherit defaults. … a missing required key now invalidates the whole file and triggers the preserve-and-reset above. **The hotkey list must contain every assignable action exactly once**; unknown, unassignable, missing, or duplicate action IDs invalidate the file.

リポジトリのファイルは以下2点で同時に違反していた。

1. **必須キーの欠損** — `[overview]` `[hiddenBar]` `[scratchpads]` セクション全体、`focus.raiseOnMouseFocus`、`focus.lockModifier`、`gaps.fullscreenUsesOuterGaps`、`general.hyperKeyModifiers`、`workspaceBar.notchMode` ほか多数。
2. **hotkey 配列の不整合** — 149件しかなく(0.6.4 は **169件を過不足なく**要求)、さらに廃止済み ID を12件含んでいた。

検証に落ちたファイルは `SettingsFilePersistence.recoverInvalidSettings` により `settings.toml.corrupt` → `.corrupt.1` の順で空きスロットに退避され、`SettingsExport`(この時点では起動直後なのでビルトイン初期値)が書き戻される。

**live ファイルがビルトイン初期値そのものである証拠**: workspace 6/7 の `displayName = "❤️" / "🚀"` と7つの workspace UUID、13件の appRules が `Sources/OmniWM/Core/Config/BuiltInSettingsDefaults.swift` のハードコード値と完全一致した。リポジトリの workspaces/appRules が「保存されたように見えた」のは、**元々そこを初期値から変更していなかった**ため。

## なぜ自動マイグレーションが効かなかったか

0.6.4 には v0 → v1 マイグレーション(`SettingsTOMLCodec.migrateVersionZero`)が実装されている。しかし補完対象は以下だけ:

- `focus.raiseOnMouseFocus = true` / `gaps.fullscreenUsesOuterGaps = false` / `workspaceBar.hideInNativeFullscreen = false` / `[scratchpads.labels]` の追加
- appRules の欠損 `id` へ UUID を付与
- hotkey ID の改名 `assignFocusedWindowToScratchpad` → `.1`、`toggleScratchpadWindow` → `.1`
- hotkey ID の廃止 `consumeOrExpelWindowLeft/Right` の除去
- scratchpad スロット 1〜10 の hotkey 追加(`appendMissingHotkeyDefaults` の `eligibleIDs` は **scratchpad 系のみ**)

つまり **0.6.2/0.6.3 が出力したファイルを 0.6.4 へ橋渡しするだけ**。0.5.9 のキー改名も 0.6.1 の resize hotkey 改名も補完しない。補完後に `CanonicalTOMLConfig` の strict decode が走るため、0.5.4 世代のファイルはそこで落ちる。upstream も 0.6.4 のノートで「Automatic migration is guaranteed for settings emitted by OmniWM 0.6.1 through 0.6.3」と範囲を明示している。

## 失われた設定の全量

### スカラー設定 8件

| キー | リポジトリの意図 | 初期値化後 |
| --- | --- | --- |
| `borders.width` | 1.0 | 5.0 |
| `gaps.size` | 1.0 | 16.0 |
| `general.ipcEnabled` | true | false |
| `focus.crossesMonitorAtEdge` | true | false |
| `focus.followsWindowToMonitor` | true | false |
| `focus.moveCrossesMonitorAtEdge` | true | false |
| `workspaceBar.reserveLayoutSpace` | true | false |
| `niri.maxVisibleColumns` = 4 | → `niri.visibleContainerCount` = 4 | 2 |

### hotkey バインド 67件

割り当て済み action の**集合自体は初期値と同一**で、違うのは binding 文字列のみ。廃止された12個の ID はすべて `Unassigned` だったため、**67件すべてが ID 一致で1:1移植可能**。`Left Option` / `Right Option` などの左右指定修飾子は 0.6.4 でも有効(バイナリ内に文字列が存在)。

### upstream から消滅したキー 3件

`general.spacesTrackingEnabled` / `workspaceBar.labelFontSize` / `workspaceBar.notchAware` は upstream コードベース全体に存在せず、直接の代替もない。notch 対応の意図は `workspaceBar.notchMode`(初期値 `"moveBelowMenuBar"`)が引き継いでいる。

## 0.5.4 → 0.6.4 の破壊的変更マップ

| バージョン | 破壊的変更 |
| --- | --- |
| 0.5.9 | `niri.maxVisibleColumns` → `visibleContainerCount` / `singleWindowAspectRatio` → `singleWindowFit`(`[niri]` `[dwindle]` および monitor overrides) / `columnWidthPresets` → `containerPrimarySpanPresets` / `defaultColumnWidth` → `defaultContainerPrimarySpan`。hotkey action ID を全面刷新 |
| 0.6.1 | `resizeGrow/Shrink.{left,right,up,down}` 8件を廃止し `.{horizontal,vertical}` へ。移行はされず drop |
| 0.6.2 | `consumeOrExpelWindowLeft/Right` が割り当て不可に(CLI のみ)。Accessibility/Input Monitoring が起動必須 |
| **0.6.3** | **完全スキーマ必須化。欠損キー1つ・hotkey 過不足でファイル全体が無効**。`focus.raiseOnMouseFocus` と `gaps.fullscreenUsesOuterGaps` が必須追加 |
| 0.6.4 | `schemaVersion = 1` 導入と v0 自動移行。scratchpad hotkey ID を `.1` 付きへ改名しスロット2〜10を追加 |

## 再発条件

- [homebrew/default.nix](../../../modules/darwin/nix-darwin/homebrew/default.nix) が `onActivation.autoUpdate = true` / `upgrade = true` のため、**`darwin-rebuild` のたびに OmniWM が最新へ上がる**。cask 単位のバージョン固定は nix-darwin の homebrew モジュールにない。
- 0.6.3 の厳格化により、**新しい必須キーが1つ追加されるだけでリポジトリのファイルは無効化される**。upstream も 0.6.4 のノートでこのケースを名指ししている("This matters if you keep `settings.toml` in a dotfiles repo, generate it from a template, or hand-merge it across machines")。
- 退避スロット `settings.toml.corrupt` / `.corrupt.1` は**両方とも使用済み**(前者は 2026-06-14 の 0.4.9.x 世代、後者は本件)。0.6.3 以降、3つ目の**別内容**の無効ファイルが来ると OmniWM はリセットせず**書き込みをブロックして fail-closed** する(`corruptBackupSlotsExhausted`)。同一内容の再投入はスロットを再利用するので枯渇しない。

## 学び

- **スロットが埋まっている状態はむしろ安全側**。次のスキーマ破壊時、黙って初期値で上書きされる代わりに書き込みがブロックされ、ファイルが手元に残る。スロットを掃除して「空ける」動機はない。
- **`settings.toml` を dotfiles で持つなら、正本は「アプリが生成した完全形」でなければならない**。手書きの部分集合は 0.6.3 以降ありえない。「アプリ生成のベース + 意図した差分」の2層に分けておけば、再同期のたびに差分だけ再適用すればよく、今回のような全損にはならない。
- **アプリ内の「リリースをスキップ」は Homebrew 管理下では無力**。バージョン制御の主導権は Nix/Homebrew 側にある。
- 169個の hotkey を過不足なく列挙する必要がある以上、**`.nix` の attrset で書き下す方針は割に合わない**([README](../../../modules/darwin/omniwm/README.md) の TOML 正本判断は妥当)。

## 次アクション

- 現在の live ファイル(0.6.4 の正規完全形)を新しいベースとして [settings.toml](../../../modules/darwin/omniwm/settings.toml) に取り込み、上記「失われた設定の全量」の8件と hotkey 67件を再適用する。hotkey 移植の入力には `~/.config/omniwm/settings.toml.corrupt.1` が使える(旧ファイルと同一)。
- 反映は [README](../../../modules/darwin/omniwm/README.md) の手順(quit → switch → open)に従い、`settings.toml.corrupt.2` が生成されないこと・`omniwmctl ping` が通ること・`schemaVersion = 1` が保たれることを確認する。
- 運用モデル(アップグレードごとの再同期を受け入れるか、OmniWM を自動アップグレード対象から外すか)を決めたら `../decision/settings-toml-sync-model.md` を作成し、本記録から相互リンクする。

## 根拠・出典

- upstream リリースノート [BarutSRB/Hiro releases](https://github.com/BarutSRB/Hiro/releases) — v0.5.9 / v0.6.1 / v0.6.2 / v0.6.3 / v0.6.4 の "Before You Upgrade — Breaking Changes"
- `Sources/OmniWM/Core/Config/SettingsTOMLCodec.swift`(v0.6.4)— `currentSchemaVersion = 1`、`decodeForLoad`、`migrateVersionZero`、`migrateVersionZeroHotkeys`
- `Sources/OmniWM/Core/Config/SettingsFilePersistence.swift`(v0.6.4)— `inspectExistingSettings`、`recoverInvalidSettings`、`secureBackup`
- `Sources/OmniWM/Core/Config/BuiltInSettingsDefaults.swift`(v0.6.4)— `workspaceConfigurations` / `appRules` のハードコード値
- インストール版 OmniWM 0.6.4(`CFBundleVersion` 75、`OMNIWMGitHash` 401b606b)

## 関連

- [modules/darwin/omniwm/settings.toml](../../../modules/darwin/omniwm/settings.toml) — 無効化された正本
- [modules/darwin/omniwm/README.md](../../../modules/darwin/omniwm/README.md) — TOML 正本の理由と反映手順
- [modules/darwin/nix-darwin/homebrew/default.nix](../../../modules/darwin/nix-darwin/homebrew/default.nix) — 自動アップグレードの設定元

<!--
ある時点のスナップショット。後で状況が変わってもこの記録は編集しない。
詳細は reference/knowledge-types.md「昇格の連鎖」。
-->
