---
title: <決定の短い名詞句>
id: <category>-<topic>-NNNN
type: decision
category: <技術ドメイン>
status: active
created: <YYYY-MM-DD>
valid_as_of: <YYYY-MM-DD>
# supersedes: <旧 decision の相対パス。置換なら>
owner: "<@handle>"
tags: [<...>]
---

<!-- 出力先: docs/<category>/decision/<slug>.md -->

> ✅ **ACTIVE（有効・<valid_as_of> 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# <決定タイトル>

## 状況 / Context
<どんな問題・制約があったか。この決定が必要になった背景>

## 決定 / Decision
<何を採用すると決めたか。1文で明確に>

## 理由 / Rationale（Why）
<なぜこれを選んだか。判断の根拠>

## 検討した選択肢 / Options
| 選択肢 | 利点 | 欠点 | 不採用理由 |
| --- | --- | --- | --- |
| <採用案> | | | （採用） |
| <代替案> | | | |

## トレードオフ・帰結 / Consequences
<この決定で何を諦め、何を得たか。将来の再評価に必要な情報>

## 関連
- <相対パスで明示リンク>

<!--
この記録は確定後イミュータブル。後で覆る場合は本文を編集せず、
新しい decision を作成して supersede する(status を superseded に、
superseded_by を後継へ)。
-->
