# reference: frontmatter スキーマ

> `writing-knowledge` の参照資料。各 frontmatter フィールドの定義と、type(validity model)による条件付き必須を定める。

## 目次
- [全フィールド定義](#全フィールド定義)
- [条件付き必須まとめ](#条件付き必須まとめ)
- [validity model 別の最小例](#validity-model-別の最小例)

---

## 全フィールド定義

```yaml
---
title: <短い名詞句のタイトル>
id: <安定した一意ID。一度発番したら廃止後も再利用しない>
type: decision | research | postmortem | rfc | reference | runbook | how-to | explanation | tutorial | glossary
category: <技術ドメイン。docs/<category>/ と一致させる>
status: active | deprecated | superseded
created: YYYY-MM-DD
valid_as_of: YYYY-MM-DD       # validity model A で必須
last_reviewed: YYYY-MM-DD     # validity model B/C で必須
review_due: YYYY-MM-DD        # validity model B/C で必須
superseded_by: <相対パス or id>  # status=superseded で必須
supersedes: <相対パス or id>     # このファイルが置き換えた旧ファイル(あれば)
owner: <@handle など責任者>
tags: [<...>]
---
```

| フィールド | 必須条件 | 意味・ルール |
| --- | --- | --- |
| `title` | 常に | 短い名詞句。ファイル内容を一言で表す |
| `id` | 常に | 安定一意ID。リネームしても不変。**廃止後も再利用しない**(壊れリンクの誤再接続を防ぐ) |
| `type` | 常に | 10種のいずれか。validity model を決定する |
| `category` | 常に | 技術ドメイン。`docs/<category>/` のディレクトリ名と一致 |
| `status` | 常に | `active`/`deprecated`/`superseded`。バナーと整合させる |
| `created` | 常に | 作成日 |
| `valid_as_of` | **model A で必須** | この知識が真だった基準時点。A はこの日付がバナーにも出る |
| `last_reviewed` | **model B/C で必須** | 最終レビュー日 |
| `review_due` | **model B/C で必須** | 次回レビュー期限。TTL は type 既定(`knowledge-types.md`)。超過=要再検証 |
| `superseded_by` | **status=superseded で必須(空欄禁止)** | 無効化した後継ファイルへの相対パス or id |
| `supersedes` | 任意 | このファイルが置き換えた旧ファイル。後継側に書く |
| `owner` | 推奨 | 責任者。レビュー・廃止判断の連絡先 |
| `tags` | 任意 | 横断検索用 |

該当しないフィールドは **省略してよい**(例: model A に `review_due` は書かない)。

---

## 条件付き必須まとめ

| status \ model | A（点時刻・不変） | B/C（鮮度・長寿命） |
| --- | --- | --- |
| `active` | `valid_as_of` | `last_reviewed` + `review_due` |
| `deprecated` | 上記 + 本文に理由/代替 | 上記 + 本文に理由/代替 |
| `superseded` | 上記 + **`superseded_by`** | 上記 + **`superseded_by`** |

- `status: superseded` のとき `superseded_by` の **空欄を許さない**。後継が無いなら `deprecated` を使う。
- `status: deprecated`(後継なし)は本文冒頭バナーに **理由と代替手段**(なければ「現時点で後継なし」)を明記。

---

## validity model 別の最小例

**model A（decision）:**
```yaml
---
title: LSP キーマップを which-key 配下に統一
id: nvim-lsp-keymap-0001
type: decision
category: nvim
status: active
created: 2026-06-21
valid_as_of: 2026-06-21
owner: "@rtosshy"
tags: [nvim, lsp, keymap]
---
```

**model B（runbook）:**
```yaml
---
title: skill を Codex CLI へ実ファイル配置する手順
id: nix-skill-deploy-0001
type: runbook
category: nix
status: active
created: 2026-06-21
last_reviewed: 2026-06-21
review_due: 2026-09-19   # 90日
owner: "@rtosshy"
tags: [nix, codex, skills]
---
```

**model A（superseded への遷移後）:**
```yaml
---
title: LSP キーマップ旧配置（gd/gr 直割り当て）
id: nvim-lsp-keymap-0000
type: decision
category: nvim
status: superseded
created: 2026-01-10
valid_as_of: 2026-01-10
superseded_by: ../decision/lsp-keymap.md   # 後継への相対パス
owner: "@rtosshy"
tags: [nvim, lsp, keymap]
---
```
