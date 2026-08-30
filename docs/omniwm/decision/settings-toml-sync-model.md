---
title: OmniWM settings.toml をベース+差分の2層で管理する
id: omniwm-settings-sync-model-0001
type: decision
category: omniwm
status: active
created: 2026-08-30
valid_as_of: 2026-08-30
owner: "@Rtosshy"
tags: [omniwm, settings-toml, nix, home-manager, config-management, layering]
---

<!-- 出力先: docs/omniwm/decision/settings-toml-sync-model.md -->

> ✅ **ACTIVE（有効・2026-08-30 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# OmniWM settings.toml をベース+差分の2層で管理する

## 状況 / Context

OmniWM 0.6.3 以降、`settings.toml` は**完全な現行スキーマでなければファイル全体が無効**になる。必須キーが1つ欠けても、hotkey 配列が全 assignable action を過不足なく含まなくても、アプリは preserve-and-reset を実行する。**部分設定という概念が存在しない**(0.6.2 までは欠損キーを既定値で補っていたが、0.6.3 で意図的に廃止された)。

この制約下で3つの事実が重なっている。

1. **再発は不可避**。[homebrew/default.nix](../../../modules/darwin/nix-darwin/homebrew/default.nix) が `onActivation.autoUpdate = true` / `upgrade = true` のため、`darwin-rebuild` のたびに OmniWM が最新へ上がる。新しい必須キーが1つ追加されるだけで正本は無効化される。
2. **意図は全体の1割以下**。850行のうち、実際に決めた設定はスカラー8件と hotkey binding 67件の計75行。残り775行はアプリが要求する定型(未割り当て hotkey 102件、appRules 13件、workspace の UUID など)で、すべて upstream の初期値そのままである。
3. **手作業での追従は既に発生している**。commit `11a14af`(2026-07-29)で hotkey action ID の改名と追加を手で当てている。

そして最も重い問題は、**破壊が静かに起きること**。実際の事故([postmortem](../postmortem/settings-toml-reset-on-0-6-4-upgrade.md))ではエラーダイアログも `darwin-rebuild` の失敗もなく、全設定が初期値に戻った。

## 決定 / Decision

`settings.toml` を **`base.toml`(アプリが生成した完全形)と `overrides.nix`(意図のみ)の2層**で管理し、ビルド時にマージして生成する。マージは **`base.toml` を再シリアライズせず、値のみをテキスト置換**する。**overrides のキーが base に存在しなければビルドを失敗させる。**

```
base.toml (canonical・アプリ生成・人は触らない)
        +  overrides.nix (意図のみ・75行)
        ↓  値の置換のみ。行構造は保つ
settings.toml (生成物・commit しない)
```

## 理由 / Rationale（Why）

**第一に、静かな設定消失をビルド失敗に変換するため。** overrides のキーが base に無ければマージが失敗し、`home-manager switch` がその場で落ちる。今回のように「気付かないうちに初期値で動いていた」状態が構造的に起きなくなる。これが2層化を選ぶ最大の理由であり、他の利点は副次的。

第二に、**意図の履歴が読めるようになる**。1層では OmniWM の canonical 書き戻しノイズと意図した変更が同じファイルに混ざり、850行が丸ごと入れ替わると git から意図を復元できない。`overrides.nix` の履歴はそのまま意図の履歴になる。

第三に、**アップグレード時の作業が縮む**。「リリースノート6本を読んで850行を直す」から「base を差し替えてマージを走らせ、弾かれた項目だけ調べる」になる。

第四に、**意図の層だけなら `.nix` で書ける**。169個の hotkey 網羅が必要な定型部分を人の管理下に置かずに済むので、普段の「設定は `.nix` で持つ」方針とも噛み合う。

### 再シリアライズしない理由

`borders.width = 1.0`(float)と `mouseWarp.margin = 1`(integer)のような型の区別は、Nix → JSON → TOML の経路で潰れうる。0.6.3 以降は**型不正もファイル全体を無効化**するため、850行を再生成する方式ではこの地雷が全キーに散らばる。触らない775行を1バイトも変えないことでリスク全体を回避する。

副次的な利点として、生成物が canonical のまま保たれるので、OmniWM が書き戻しても差分が出ない。

## 検討した選択肢 / Options

| 選択肢 | 利点 | 欠点 | 不採用理由 |
| --- | --- | --- | --- |
| **2層化(base + overrides)** | 静かな消失がビルド失敗になる / 意図が75行に凝縮 / 意図の層を `.nix` で書ける | マージ機構の保守 / base 取得に人手 | (採用) |
| 1層のまま、壊れたら都度手作業 | 仕組みが不要 | 追従が考古学になる / 壊れても気付かない | 追従は既に一度発生済み(`11a14af`)。再発コストが読めず、検知手段が無いのが致命的 |
| 自動アップグレードを止める | 破壊の発生自体を制御できる | `onActivation.upgrade` はグローバル設定で cask 単位の固定手段が無い / 機能追従を諦める | 実現手段が不確実。ただし2層化と排他ではないので将来 revisit 可 |
| 全部 `.nix` attrset で書き下す | 型もコメントも効く | 169 hotkey の網羅を人が持つ / 再シリアライズの型リスク | 定型775行を人の管理下に置く意味がない |
| Nix でマージして TOML を再生成 | 実装が素直 | float/integer の欠落が全キーに及ぶ | 型不正がファイル全体を無効化するため危険 |

## トレードオフ・帰結 / Consequences

**得たもの**

- キーの改名・削除が `home-manager switch` の失敗として即座に現れる
- `overrides.nix` の git 履歴 = 意図の履歴
- appRules・未割り当て hotkey・UUID など775行が視界から消える

**諦めたもの**

- `base.toml` 850行はリポジトリに残る。ビルド入力として必須なので削れない。**人が読まない・触らないファイル**として扱う規約でカバーする
- `python3` がビルド依存に入る(`tomllib` による検証に使う)
- **`base.toml` の取得は自動化できない**。「設定ファイルが無い状態で OmniWM を起動して吐かせる」人手が要る

**前提として維持するもの**

- 生成された `settings.toml` は commit しない
- `home.activation` で実ファイルとして配置する現行方式は維持する。OmniWM が書き戻すため symlink にはできない([README](../../../modules/darwin/omniwm/README.md) の判断は引き続き有効)
- 自動アップグレードは止めない。**破壊は起きる前提で、検知可能にする**のがこの決定の立場

**`base.toml` の不変条件**

`base.toml` は必ず「設定ファイルが無い状態で OmniWM を起動して吐かせたもの」であること。稼働中インスタンスからコピーすると GUI 変更が混ざり、意図が2層に散って2層化の意味が失われる。

**再評価の条件**

- OmniWM がスキーマを安定させ破壊的変更が止んだら、この仕組みは過剰になる
- nix-darwin の homebrew モジュールが cask 単位のバージョン固定を持ったら、「自動アップグレードを止める」案を再検討する余地がある

## 関連

- [postmortem: OmniWM 0.6.4 への自動アップグレードで settings.toml が全損し初期設定に戻った](../postmortem/settings-toml-reset-on-0-6-4-upgrade.md) — この決定の発端となった事故の記録
- [modules/darwin/omniwm/README.md](../../../modules/darwin/omniwm/README.md) — TOML 正本の理由と反映手順
- [modules/darwin/nix-darwin/homebrew/default.nix](../../../modules/darwin/nix-darwin/homebrew/default.nix) — 自動アップグレードの設定元

<!--
この記録は確定後イミュータブル。後で覆る場合は本文を編集せず、
新しい decision を作成して supersede する(status を superseded に、
superseded_by を後継へ)。
-->
