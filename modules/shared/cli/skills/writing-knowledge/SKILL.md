---
name: writing-knowledge
description: 今回のセッションで得た知見を `docs/<category>/<type>/<slug>.md` 形式のナレッジファイルとして残すための規約スキル(明示起動専用)。`<category>` は nvim・omniwm・nix・wezterm のような技術ドメイン、その下を type で分ける。まず知見の種類(type: decision/research/postmortem/rfc/reference/runbook/how-to/explanation/tutorial/glossary)を判定して validity model(点時刻・不変 / 鮮度 / 長寿命)を選び、frontmatter とステータスバナーの二重表現で「今このファイルは有効か・無効なら次にどこを見るか」を必ず明示させる。陳腐化したナレッジは静かに無視されるのではなく自信を持って誤実行されるため、有効性の可視化が最優先。`/writing-knowledge`(Claude) または `$writing-knowledge`(Codex) で起動する。
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date:*)
  - Bash(rg:*)
  - Bash(fd:*)
---

# writing-knowledge — ナレッジを書くためのナレッジ

明示起動専用。**今回のセッションで得た知見を、再利用可能なナレッジファイルとして `docs/<category>/<type>/<slug>.md` に外部化する** ための規約。

ナレッジは内容の誤りよりも **「陳腐化が不可視であること」** で壊れる。古いナレッジはエージェントに静かに無視されるのではなく、**自信を持って誤実行される**。

このスキルの最重要責務は2つ。

1. 各ナレッジファイルが **「今有効か / 無効か」を一目で判定可能** であること。
2. 無効なら **次に見るべきファイルへ確実に誘導** すること。

そのために、すべてのナレッジに **種類(type)** を割り当て、種類ごとの **老い方(validity model)** に応じてメタデータ・TTL・編集方針を切り替える。

---

## 最優先の2不変条件

type に関わらず常に守る。残りは詳細。

### 不変条件 ① 種類を最初に判定する

作成・更新の **最初のステップ** は必ず type 判定 → validity model 決定。validity model が「必須メタデータ・既定 TTL・編集方針」を決める。判定せずに書き始めない。
→ 詳細・判定フロー: `reference/knowledge-types.md`

### 不変条件 ② 二重表現で有効性を出力する

すべてのナレッジは **frontmatter(機械可読)** と **本文1行目のステータスバナー(人間・エージェントが最初に必ず読む)** の両方を持つ。frontmatter は読み飛ばされうるので、可視のバナーが命綱。
→ 後述「ステータスバナー」。frontmatter 全定義: `reference/frontmatter-schema.md`

---

## 出力先：`docs/<category>/<type>/<slug>.md`

- **`<category>` は技術ドメイン**。リポの構成に合わせる(例: `nvim`, `omniwm`, `nix`, `wezterm`, `claude`, `codex`, `fish`, `git`)。
- **`<type>` は知見の種類**(`decision`/`research`/`runbook`/… frontmatter の `type` と一致させる)。category の下を type で分けることで、同じドメインの「決定」と「手順」が混ざらない。
- **`<slug>` はタイトルの kebab**。type は path で表れるので slug に接尾辞は不要。
- ファイル数が少ないドメインは `docs/<category>/<slug>.md` のフラット配置でもよい。迷ったら type 階層を切る(後から増えても破綻しない)。
- **跨ドメイン時の category 決定(primary-domain rule)**: 1セッションが複数ドメインに跨るときは、**「その知識を最も特定する制約があるドメイン」を primary** として、そこに置く。例: 「Codex は symlink を辿らない」知見は nix/claude にも触れるが、判断を縛っている固有制約は Codex 由来 → `category: codex`。残りのドメインからは相互リンクで繋ぐ(1階層)。「広く関係する」ドメインではなく「その知見が無ければ困る」ドメインを選ぶ。

例:
```
docs/nvim/decision/lsp-keymap.md       # type: decision, category: nvim
docs/omniwm/research/scratchpad.md     # type: research, category: omniwm
docs/nix/runbook/skill-deploy.md       # type: runbook,  category: nix
```

---

## validity model（3分類）

type は増えても、必ずこの3つのどれかに帰着させる。これがメタデータと運用の破綻を防ぐ。

| model | 老い方 | type 例 | 編集方針 | 必須メタデータ | 既定 review TTL |
| --- | --- | --- | --- | --- | --- |
| **A 点時刻・不変**(置換) | 「`valid_as_of` 時点で真」。後で間違っても**編集せず**新ファイルで置換 | `decision`(ADR), `research`, `postmortem`, `rfc` | 確定後イミュータブル。変更=新規+supersede | `valid_as_of`, `status`, (superseded時) `superseded_by` | レビュー不要(リンク健全性のみ) |
| **B 生もの・鮮度** | 現実とズレた瞬間に無効 | `reference`, `runbook`, `how-to` | in-place 編集で常に最新化 | `last_reviewed`, `review_due` | `runbook`=90日 / `reference`・`how-to`=180日 |
| **C 長寿命・低頻度** | 概念が変わらない限り有効 | `explanation`, `tutorial`, `glossary` | in-place 編集。概念変化時のみ | `last_reviewed`, `review_due` | 365日 |

判定に迷ったら「読み手のニーズ」で切る:
学ぶ=`tutorial` / やる=`how-to`・`runbook` / 調べる=`reference` / 理解する=`explanation` / なぜ決めたか=`decision` / 何を調べたか=`research`。

**1ファイルに複数 type を混ぜない。** 混ざりそうなら分割する。

`rfc` は提案段階。受理されたら対応する `decision` を新規作成し、`rfc` を `superseded` にして決定へ向ける(提案→決定の連鎖を残す)。

---

## このセッションをナレッジ化する（主ワークフロー）

`/writing-knowledge` 起動時の既定の流れ。コピーして進捗を追う。

- [ ] **何が残す価値のある知見か** を1〜2文で言語化(結論 + なぜ)
- [ ] **type を判定** → validity model を決める(`reference/knowledge-types.md`)
  - 「Xを採用すると決めた / 却下した」→ `decision`
  - 「Xを調べた・試した結果こうだった」→ `research`
  - 「障害が起きて原因と対応はこうだった」→ `postmortem`
  - 「手順が固まった(再現実行する)」→ `runbook`(高stakes) / `how-to`
  - 「事実・設定・APIの一覧」→ `reference`
  - 「概念・背景の理解」→ `explanation`
  - **発見と決定が混在する1セッション**は、結論(やる/やらない)が主役なら `decision` を主にし、発見はその Context に畳む。発見自体が大きく単独で参照価値があるなら `research` に分割して decision と相互リンク。1ファイルに混ぜない
- [ ] **`<category>`(技術ドメイン)を決める** → 出力先 `docs/<category>/<type>/<slug>.md`
- [ ] validity model の **必須メタデータと既定 TTL** を確認
- [ ] 対応する `templates/` を複製(`decision`/`research`/`reference`/`runbook`、無ければ `templates/knowledge-template.md`)
- [ ] frontmatter 記入(type, category, status=active, A は `valid_as_of` / B・C は `last_reviewed`+`review_due`)。`category` は `docs/<category>/` と一致
- [ ] ステータスバナー記入(model に応じた表記)
- [ ] セッションから **Why・トレードオフ・結論** を抽出して本文に。時限的散文(「今は〜」)は禁止
- [ ] 関連ナレッジ・コードへの相互リンク / 100行超なら目次

詳細・廃止/レビューのチェックリスト: `checklists/authoring-checklist.md`

---

## frontmatter（要約）

完全な定義と条件付き必須は `reference/frontmatter-schema.md`。最小形:

```yaml
---
title: <短い名詞句>
id: <安定一意ID。廃止後も再利用しない>
type: decision | research | postmortem | rfc | reference | runbook | how-to | explanation | tutorial | glossary
category: <技術ドメイン. docs/<category>/ と一致させる>
status: active | deprecated | superseded
created: YYYY-MM-DD
valid_as_of: YYYY-MM-DD       # model A で必須
last_reviewed: YYYY-MM-DD     # model B/C で必須
review_due: YYYY-MM-DD        # model B/C で必須(TTL は type 既定)
superseded_by: <相対パス or id>  # status=superseded で必須(空欄禁止)
supersedes: <相対パス or id>     # 旧ファイルを置換したなら
owner: <@handle>
tags: [<...>]
---
```

- `type` の validity model に対応する必須メタデータを満たす。該当しないフィールドは省略可。
- `category` は `docs/<category>/` のディレクトリ名と一致させる。
- `status: superseded` は `superseded_by` **必須**(空欄禁止)。
- `status: deprecated`(後継なし)は本文に代替手段か理由を明記。
- 後継ができたら旧ファイルを **削除・改変せず** `status: superseded` + `superseded_by` を後継へ。後継側は `supersedes` で旧を指す。**真実は最新の1枚ではなく連鎖全体**。

---

## ステータスバナー（本文1行目・必須）

validity model で表記を変える。日付・タイトルは実値で埋める。

**有効 / model B・C（鮮度・長寿命）:**
```markdown
> ✅ **ACTIVE（有効）** — 最終レビュー: {last_reviewed} ／ 次回レビュー期限: {review_due}
```

**有効 / model A（点時刻・不変）:**
```markdown
> ✅ **ACTIVE（有効・{valid_as_of} 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。
```

**置換された（最重要。どこで無効化され、どこを見ればよいか）:**
```markdown
> ⛔ **SUPERSEDED（無効）** — このナレッジは {superseded date} に {後継タイトル}（{superseded_by}）によって置き換えられました。**最新情報は必ず後継ファイルを参照してください。** 本ファイルは履歴・経緯の保存目的でのみ残しています。
```

**非推奨（後継なし）:**
```markdown
> ⚠️ **DEPRECATED（非推奨）** — このナレッジはもう推奨されません。理由: {理由}。代替: {代替手段 or "現時点で後継なし"}。
```

**期限切れ（model B/C で `review_due` 超過だが内容は active）:**
```markdown
> ✅ **ACTIVE（有効・レビュー期限超過：再検証が必要）** — 最終レビュー: {last_reviewed} ／ 次回レビュー期限: {review_due}（超過）
```

遷移規則と例の詳細: `reference/status-lifecycle.md`

---

## ナレッジ・ベストプラクティス（規約）

1. **1ファイル1トピック・1 type**。小さくモジュラーに(大きい文書は更新されない)。
2. **Why を残す**。結論だけでなく「なぜ・トレードオフ」。後の読み手が再評価できるように。
3. **時限的な散文を禁止**。「20XX年以前は旧手順」のような日付ロジックを本文に埋めない。陳腐化は `status`+置換リンク、または `review_due` で表現する。旧手順を残すなら本文末尾の「Old patterns」を `<details>` で折りたたみ、歴史的文脈として置く。
4. **相互参照は1階層・明示リンク**。相対パスで明示し、曖昧表現と深いネスト参照を避ける。
5. **100行超は冒頭に目次**。部分読みでも全体像が分かるように。
6. **用語を統一**(同じ概念を別語で呼ばない)。
7. **簡潔に**。読み手は賢い前提で自明な説明を省く。トークンは公共財。

---

## 他ワークフロー（廃止・レビュー）

詳細は `checklists/authoring-checklist.md`。

### 廃止・置換
- [ ] 後継ファイル作成 → 後継に `supersedes` 設定
- [ ] 旧ファイルを `status: superseded` + `superseded_by` 設定(**削除・改変しない**。model A は特に厳守)
- [ ] 旧バナーを SUPERSEDED に書き換え → 双方向リンクの整合確認

### レビュー（主に model B/C）
- [ ] `review_due` 超過ファイルを検出 → 内容再検証 → `last_reviewed`/`review_due` 更新 or 廃止
- [ ] model A は原則レビュー対象外(後継チェーンのリンク健全性のみ確認)

---

## どこを見るか（1階層参照）

| 知りたいこと | ファイル |
| --- | --- |
| type 一覧・validity model 対応・判定フロー・type別 TTL | `reference/knowledge-types.md` |
| frontmatter 全フィールド定義・条件付き必須 | `reference/frontmatter-schema.md` |
| active→deprecated→superseded の遷移規則と例 | `reference/status-lifecycle.md` |
| 作成・更新・廃止のチェックリスト | `checklists/authoring-checklist.md` |
| 空テンプレ(type プレースホルダ) | `templates/knowledge-template.md` |
| ADR / 調査 / リファレンス / runbook テンプレ | `templates/decision.md` ほか |
