# checklist: ナレッジの作成・更新・廃止

> `writing-knowledge` の作業チェックリスト。コピーして進捗を追う。**先頭は必ず種類判定**。

## 0. 種類判定（すべての作業の最初）
- [ ] このセッションで残す知見を1〜2文で言語化(結論 + なぜ)
- [ ] `type` を判定(`../reference/knowledge-types.md` の判定フロー)
- [ ] type → validity model(A 点時刻・不変 / B 鮮度 / C 長寿命)を確定
- [ ] その validity model の **必須メタデータ** と **既定 TTL** を確認

---

## A. 新規作成
- [ ] `<category>`(技術ドメイン)を決める
- [ ] 出力先 `docs/<category>/<type>/<slug>.md` を決める(`<slug>` はタイトル kebab)
- [ ] 対応する `templates/` を複製
      (`decision`/`research`/`reference`/`runbook`、無ければ `templates/knowledge-template.md`)
- [ ] frontmatter 記入
  - [ ] `title` / `id`(安定一意・再利用しない) / `type` / `category` / `created`
  - [ ] `status: active`
  - [ ] model A → `valid_as_of`
  - [ ] model B/C → `last_reviewed` + `review_due`(type 既定 TTL)
- [ ] ステータスバナーを1行目に記入(model に応じた表記)
- [ ] 本文に **Why・トレードオフ・結論** を抽出。時限的散文(「今は〜」)を書いていないか
- [ ] 関連ナレッジ・コードへ相対パスで明示リンク(1階層)
- [ ] 100行超なら冒頭に目次
- [ ] 用語は統一されているか / 1ファイル1 type を守っているか

---

## B. 更新（in-place、主に model B/C）
- [ ] 対象は model B/C か(model A は in-place 編集しない → C 廃止/置換へ)
- [ ] 現実と一致するよう本文を最新化
- [ ] `last_reviewed` を今日に、`review_due` を TTL 先に更新
- [ ] バナーの日付を更新
- [ ] 構造ごと作り直すレベルなら、更新ではなく置換(C)を検討

---

## C. 廃止・置換
- [ ] 後継があるか?
  - **あり → superseded**
    - [ ] 後継ファイルを作成し、後継に `supersedes`(旧への相対パス)を設定
    - [ ] 旧ファイルを `status: superseded` + `superseded_by`(後継への相対パス)に変更
    - [ ] 旧ファイルを **削除・改変しない**(model A は本文も触らない。バナーと status のみ)
    - [ ] 旧バナーを ⛔ SUPERSEDED に書き換え(後継タイトルとパスを明示)
    - [ ] 双方向リンク(`superseded_by` ⇄ `supersedes`)の整合を確認
  - **なし → deprecated**
    - [ ] `status: deprecated` に変更
    - [ ] バナーを ⚠️ DEPRECATED に。理由と代替(なければ「現時点で後継なし」)を明記

---

## D. レビュー（主に model B/C）
- [ ] `review_due` 超過ファイルを検出(例: `rg -l 'review_due' docs/` → 日付確認)
- [ ] 内容を現実と突き合わせて再検証
- [ ] OK → `last_reviewed`/`review_due` 更新、バナーから「期限超過」表記を除去
- [ ] NG → 更新(B)または廃止/置換(C)
- [ ] model A は原則レビュー対象外。後継チェーンのリンク健全性のみ確認
      (`superseded_by`/`supersedes` のリンク切れがないか)
