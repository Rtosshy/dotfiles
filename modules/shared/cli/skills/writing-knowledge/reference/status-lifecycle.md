# reference: ステータスのライフサイクル

> `writing-knowledge` の参照資料。`active → deprecated → superseded` の遷移規則と具体例。frontmatter の `status` と本文バナーは**常に整合**させる。

## 状態の意味

| status | 意味 | 後継 | バナー |
| --- | --- | --- | --- |
| `active` | 有効。今これに従ってよい | — | ✅ ACTIVE |
| `deprecated` | 非推奨。後継は無いが、もう従うべきでない | なし | ⚠️ DEPRECATED |
| `superseded` | 置換済み。**後継を見ること** | あり(`superseded_by` 必須) | ⛔ SUPERSEDED |

「有効か」「無効化元(後継)」「参照先」の3情報を必ず残す。社内で `draft/approved` 等を使うならこの3情報を保てる範囲で語彙を置換してよい。

---

## 遷移規則

```
            ┌──────────────┐
   作成 ──▶ │   active     │
            └──────┬───────┘
                   │
       ┌───────────┴────────────┐
       ▼                        ▼
┌──────────────┐        ┌──────────────────┐
│ deprecated   │        │   superseded     │
│ (後継なし)    │        │ (後継あり=必須)   │
└──────────────┘        └──────────────────┘
```

- **active → superseded**: 後継ファイルができたとき。旧を**削除・改変せず** `status: superseded` + `superseded_by` を後継へ。後継側は `supersedes` で旧を指す(双方向)。
- **active → deprecated**: もう推奨しないが置き換える後継が無いとき。理由と代替(あれば)を本文に。
- **deprecated → superseded**: 後から後継ができたら昇格。`superseded_by` を設定。
- **model A は確定後イミュータブル**: 誤りが見つかっても本文を書き換えず、新記録で supersede する。バナーと status 以外は触らない。
- **逆遷移しない**: 一度 superseded/deprecated にしたファイルを active に戻さない。復活させたい内容は新ファイルとして作る。

---

## 例：active → superseded（model A / decision）

**旧ファイル `docs/nvim/decision/lsp-keymap-v0.md`**(置換後):
```markdown
---
title: LSP キーマップ旧配置
id: nvim-lsp-keymap-0000
type: decision
category: nvim
status: superseded
created: 2026-01-10
valid_as_of: 2026-01-10
superseded_by: ./lsp-keymap.md
---

> ⛔ **SUPERSEDED（無効）** — このナレッジは 2026-06-21 に [LSP キーマップを which-key 配下に統一](./lsp-keymap.md)（./lsp-keymap.md）によって置き換えられました。**最新情報は必ず後継ファイルを参照してください。** 本ファイルは履歴・経緯の保存目的でのみ残しています。

（以下、当時の決定本文はそのまま保存）
```

**後継ファイル `docs/nvim/decision/lsp-keymap.md`:**
```markdown
---
title: LSP キーマップを which-key 配下に統一
id: nvim-lsp-keymap-0001
type: decision
category: nvim
status: active
created: 2026-06-21
valid_as_of: 2026-06-21
supersedes: ./lsp-keymap-v0.md
---

> ✅ **ACTIVE（有効・2026-06-21 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。
```

双方向リンク(`superseded_by` ⇄ `supersedes`)が揃っていることを必ず確認する。

---

## 例：active → deprecated（後継なし）

```markdown
> ⚠️ **DEPRECATED（非推奨）** — このナレッジはもう推奨されません。理由: 当該プラグインを撤去したため。代替: 現時点で後継なし(必要になれば runbook を新設)。
```

---

## 例：期限切れ（model B/C、review_due 超過だが内容は active）

内容がまだ正しいと確認できるまでは active のまま、バナーで再検証フラグを立てる:
```markdown
> ✅ **ACTIVE（有効・レビュー期限超過：再検証が必要）** — 最終レビュー: 2026-01-05 ／ 次回レビュー期限: 2026-04-05（超過）
```
再検証したら `last_reviewed`/`review_due` を更新して通常の ACTIVE バナーに戻す。現実とズレていたら in-place 修正、または(B/C でも構造ごと作り直すなら)superseded にする。
