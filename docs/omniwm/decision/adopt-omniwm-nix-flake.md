---
title: OmniWM の導入と設定を omniwm.nix flake に委ねる
id: omniwm-adopt-nix-flake-0001
type: decision
category: omniwm
status: active
created: 2026-09-21
valid_as_of: 2026-09-21
supersedes: ./settings-toml-sync-model.md
owner: "@Rtosshy"
tags: [omniwm, settings-toml, nix, home-manager, flake, homebrew, config-management]
---

<!-- 出力先: docs/omniwm/decision/adopt-omniwm-nix-flake.md -->

> ✅ **ACTIVE（有効・2026-09-21 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# OmniWM の導入と設定を omniwm.nix flake に委ねる

## 状況 / Context

[前任の決定](./settings-toml-sync-model.md)は、OmniWM が不完全な `settings.toml` をファイルごと破棄する制約に対し、`base.toml`(アプリ生成の完全形)+ `overrides.nix`(意図のみ)の2層で対抗した。overrides のキーが base に無ければビルドを落とすことで、**静かな設定消失をビルド失敗に変換する**のが狙いだった。

狙いは達成されたが、代償として次の3つがリポジトリに残っていた。

1. **`base.toml` 980行**。人が読まない・触らないファイルとして規約でカバーしていた
2. **`merge.py` 500行**。TOML を再シリアライズせず行単位で値だけ差し替える独自マージ機構
3. **`base.toml` の取得は自動化できない**。アップグレードのたびに「設定ファイルが無い状態で OmniWM を起動して吐かせる」人手が要る

つまり2層化は**完全形の追従コストを消したのではなく、人手の一手順に押し込んだだけ**だった。実際その追従は滞っており、cask は 0.6.10 まで上がっていたのに `base.toml` は `schemaVersion = 1` のまま、0.6.9 で削除された `monitorRoutingOverrides` を書き続けていた。

ここで [mst-mkt/omniwm.nix](https://github.com/mst-mkt/omniwm.nix) が、**まさにこの完全形の追従を引き受ける** flake として登場した。upstream のソースから `settings-defaults.toml` を生成する codegen を持ち、CI がバージョン bump と同時に日次で再生成する。

## 決定 / Decision

OmniWM の**パッケージと設定の両方**を omniwm.nix flake に委ねる。Homebrew cask をやめ、nix パッケージ + launchd agent へ移す。

```
flake input: github:mst-mkt/omniwm.nix
        ↓  homeManagerModules.default (HM 内蔵 programs.omniwm を置き換える)
programs.omniwm.settings = { 意図のみ・75行 }
        ↓  パッケージ版に同梱された defaults へ deep merge。hotkeys は id 単位
settings.toml (生成物・書き込み可能な実ファイルとして配置)
```

リポジトリから `base.toml` / `merge.py` / `overrides.nix` が消え、[modules/darwin/omniwm/default.nix](../../../modules/darwin/omniwm/default.nix) 1枚になる。意図した設定の内容は**スカラー8件 + hotkey 67件のまま1件も変わらない**。

## 理由 / Rationale（Why）

**第一に、完全形の追従が upstream の CI の仕事になるため。** 前任の決定が「諦めたもの」として明記していた手作業(`base.toml` の取得)が、そもそも発生しなくなる。パッケージのバージョンを上げれば defaults がついてくる。これが委譲を選ぶ最大の理由。

第二に、**検知手段は失われない**。2層化の核心だった「意図したキーが upstream から消えたらビルドを落とす」性質は、flake 側の assertion が引き継ぐ。未知の hotkey id は評価時に落ち、エラーメッセージが不明な id を列挙する。スカラーは静かに増えるだけなので落ちないが、`settings.toml` を破棄させる条件ではない。

第三に、**型の地雷が解けた**。前任の決定が再シリアライズを避けた理由は「Nix → JSON → TOML で float/integer の区別が潰れうる」ことだった。`pkgs.formats.toml` は Nix の float をそのまま TOML の float として書く。生成物で `borders.width = 1.0`(float)と `niri.visibleContainerCount = 4`(integer)が区別されていることを確認済み。

第四に、**cask をやめることが前提の一つを解消する**。前任の決定は「自動アップグレードは止めない。破壊は起きる前提で検知可能にする」立場だったが、これは `homebrew.onActivation.upgrade` が cask 単位の固定手段を持たないことへの妥協だった。nix パッケージならバージョンは flake.lock に固定され、`nix flake update` の意図的な操作でしか動かない。

## トレードオフ・帰結 / Consequences

**得たもの**

- `base.toml` 980行 + `merge.py` 500行が消えた。python3 のビルド依存も消えた
- OmniWM のバージョンが flake.lock に固定される。`darwin-rebuild` のたびに黙って上がることがなくなった
- `settings.toml` の `schemaVersion` がパッケージのバージョンに追従する(移行時点で 1 → 3)

**諦めたもの**

- **完全形の正しさを upstream に預けた**。omniwm.nix の codegen が壊れたり更新が止まったりすれば、こちらからは見えない。リポジトリの CI と更新頻度が信頼の根拠
- **アクセシビリティ等の macOS 権限が nix store のパスに紐づく**。バージョンを上げるとパスが変わるため、再付与を求められる可能性がある
- **スカラー設定のキー改名は検知できない**。deep merge は未知のキーを黙って受け入れる。hotkey id のような assertion は無い

**前提として維持するもの**

- 生成された `settings.toml` は commit しない
- 実ファイルとして配置する(`mutableSettings = true`、モジュールの既定)。OmniWM が起動時に書き戻すため symlink にはできない。この判断は前任の決定から不変
- GUI での変更は次回の activation で上書きされる。意図は `.nix` に書く

**再評価の条件**

- omniwm.nix の更新が止まったら、fork するか2層モデルへ戻すかを検討する
- nixpkgs 本体に OmniWM が入り、Home Manager 内蔵の `programs.omniwm` が defaults マージを持つようになったら、flake 依存を落とせる

## 関連

- [decision: OmniWM settings.toml をベース+差分の2層で管理する](./settings-toml-sync-model.md) — この決定が置き換えた前任
- [postmortem: OmniWM 0.6.4 への自動アップグレードで settings.toml が全損し初期設定に戻った](../postmortem/settings-toml-reset-on-0-6-4-upgrade.md) — 一連の判断の発端となった事故の記録
- [modules/darwin/omniwm/README.md](../../../modules/darwin/omniwm/README.md) — 設定変更と反映の手順
- [mst-mkt/omniwm.nix](https://github.com/mst-mkt/omniwm.nix) — 委譲先の flake

<!--
この記録は確定後イミュータブル。後で覆る場合は本文を編集せず、
新しい decision を作成して supersede する(status を superseded に、
superseded_by を後継へ)。
-->
