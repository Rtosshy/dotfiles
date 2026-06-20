---
title: <手順の短い名詞句>
id: <category>-<topic>-NNNN
type: runbook
category: <技術ドメイン>
status: active
created: <YYYY-MM-DD>
last_reviewed: <YYYY-MM-DD>
review_due: <YYYY-MM-DD>   # 既定 TTL 90日（高stakes・誤実行の代償が大きいので短め）
owner: "<@handle>"
tags: [<...>]
---

<!-- 出力先: docs/<category>/runbook/<slug>.md -->

> ✅ **ACTIVE（有効）** — 最終レビュー: <YYYY-MM-DD> ／ 次回レビュー期限: <YYYY-MM-DD>

# <runbook タイトル>

## 目的 / When to run
<どういうとき実行するか。前提条件・トリガー>

## 前提 / Preconditions
- <実行前に満たすべき状態。破壊的操作なら特に明記>

## 手順 / Steps
1. <コマンドと期待される出力をペアで>
   ```sh
   <command>
   ```
   期待: <こうなれば成功>
2. ...

## 失敗時 / Rollback
<途中で失敗したらどう戻すか。高stakes runbook では必須>

## 検証 / Verify
<完了をどう確認するか>

## 関連
- <相対パスで明示リンク>

<!--
生もの・高stakes。現実とズレると誤実行を招く。in-place で常に最新化。
review_due(90日)超過時は実際に手順を再検証してから更新する。
-->
