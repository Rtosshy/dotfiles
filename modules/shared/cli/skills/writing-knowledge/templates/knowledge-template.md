---
title: <短い名詞句のタイトル>
id: <category>-<topic>-NNNN
type: <decision | research | postmortem | rfc | reference | runbook | how-to | explanation | tutorial | glossary>
category: <技術ドメイン。docs/<category>/ と一致>
status: active
created: <YYYY-MM-DD>
# --- validity model A（decision/research/postmortem/rfc）のとき ---
valid_as_of: <YYYY-MM-DD>
# --- validity model B/C（reference/runbook/how-to/explanation/tutorial/glossary）のとき ---
# last_reviewed: <YYYY-MM-DD>
# review_due: <YYYY-MM-DD>   # TTL: runbook=90日 / reference・how-to=180日 / 長寿命=365日
owner: "<@handle>"
tags: [<...>]
---

<!-- 出力先: docs/<category>/<type>/<slug>.md -->
<!-- model に応じてバナーを1つ選び、不要なものは消す -->

> ✅ **ACTIVE（有効）** — 最終レビュー: <YYYY-MM-DD> ／ 次回レビュー期限: <YYYY-MM-DD>
<!-- model A のときは代わりに:
> ✅ **ACTIVE（有効・<valid_as_of> 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。
-->

# <タイトル>

<!-- 100行を超えるなら、ここに目次を置く -->

## 要約
<一言で。読み手がこのファイルを開くべきか判断できるように>

## 本文
<type に応じた中身。Why とトレードオフを必ず残す。「今は〜」のような時限的散文は書かない>

## 関連
- <相対パスで明示リンク。1階層まで>

<!-- 歴史的文脈を残したいときだけ:
<details>
<summary>Old patterns（歴史的文脈・現在は無効）</summary>

<旧手順や旧決定の経緯。本文の現行手順とは混ぜない>
</details>
-->
