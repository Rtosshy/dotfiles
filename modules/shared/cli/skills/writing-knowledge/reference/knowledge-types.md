# reference: ナレッジの種類と validity model

> このファイルは `writing-knowledge` スキルの参照資料。type を判定し、対応する validity model・必須メタデータ・既定 TTL・編集方針を決めるために読む。

## 目次
- [大原則：3つの validity model に帰着させる](#大原則3つの-validity-model-に帰着させる)
- [type 一覧表](#type-一覧表)
- [判定フロー](#判定フロー)
- [rfc → decision の連鎖](#rfc--decision-の連鎖)
- [category（技術ドメイン）との関係](#category技術ドメインとの関係)

---

## 大原則：3つの validity model に帰着させる

type は実態に合わせて足し引きしてよい。ただし **必ず A/B/C のどれかに割り当てる**。これを守る限り、メタデータと運用は破綻しない。

- **A 点時刻・不変（置換モデル）** … 「ある時点で真」のスナップショット。後で現実が変わっても**記録自体は無効化されない**。間違いが見つかっても編集せず、新しい記録で置換(supersede)する。真実は最新の1枚ではなく**連鎖全体**。
- **B 生もの・鮮度モデル** … 現実と一致が命。ズレた瞬間に陳腐化する。in-place 編集で常に最新に保ち、レビュー期限(`review_due`)でゲートする。
- **C 長寿命・低頻度** … 概念ベースでゆっくり老いる。概念が変わらない限り有効。レビューは低頻度で十分。

---

## type 一覧表

| type | validity model | 読み手のニーズ | 老い方／有効性の意味 | 編集方針 | 必須メタデータ | 既定 review TTL |
| --- | --- | --- | --- | --- | --- | --- |
| `decision`(ADR) | **A** | なぜ決めたか | `valid_as_of` 時点の決定。後で覆っても編集せず supersede | 確定後イミュータブル | `valid_as_of`, `status`, (superseded時)`superseded_by` | レビュー不要(リンク健全性のみ) |
| `research` | **A** | 何を調べたか | ある時点の調査/スパイク結果のスナップショット | 確定後イミュータブル | 同上 | 同上 |
| `postmortem` | **A** | 何が起きたか | ある時点の障害記録。事実は変わらない | 確定後イミュータブル | 同上 | 同上 |
| `rfc` | **A** | 何を提案したか | 提案段階の記録。受理で `decision` に置換 | 確定後イミュータブル | 同上 | 同上 |
| `reference` | **B** | 調べる | 現実(設定/API/事実)とズレたら無効 | in-place で最新化 | `last_reviewed`, `review_due` | 180日 |
| `runbook` | **B** | やる(高stakes) | 手順が現実とズレたら誤実行を招く | in-place で最新化 | `last_reviewed`, `review_due` | **90日**(代償が大きいので短め) |
| `how-to` | **B** | やる | 手順が現実とズレたら無効 | in-place で最新化 | `last_reviewed`, `review_due` | 180日 |
| `explanation` | **C** | 理解する | 概念が変わらない限り有効 | 概念変化時のみ更新 | `last_reviewed`, `review_due` | 365日 |
| `tutorial` | **C** | 学ぶ | 学習の筋道。基盤技術が変わるまで有効 | 概念変化時のみ更新 | `last_reviewed`, `review_due` | 365日 |
| `glossary` | **C** | 用語を引く | 用語定義。概念が変わらない限り有効 | 概念変化時のみ更新 | `last_reviewed`, `review_due` | 365日 |

- `status`(active/deprecated/superseded)とステータスバナーは **全 type 共通で必須**。
- 違うのは「無効化の主な引き金」: **A = 後継による置換** / **B・C = 鮮度切れ or 再構成**。
- TTL は type 既定を出発点にし、ファイル個別に上書きしてよい(高stakes な reference は短く、安定した how-to は長く)。

---

## 判定フロー

種類が曖昧なときは **「この知見の読み手は何をしたいか」** で切る。

```
このセッションで残す知見は……
├─ 「なぜそう決めたか」を残したい           → decision   (A)
├─ 「何を調べた/試した結果こうだった」      → research   (A)
├─ 「障害が起きて原因と対応はこうだった」    → postmortem (A)
├─ 「こう変えたいと提案したい(未確定)」    → rfc        (A) ※受理で decision へ
├─ 「やり方(高stakes・手順厳守)」          → runbook    (B)
├─ 「やり方(通常の手順)」                  → how-to     (B)
├─ 「事実・設定・APIを引けるようにしたい」  → reference  (B)
├─ 「概念・背景を理解させたい」              → explanation(C)
├─ 「初学者を手取り足取り学ばせたい」        → tutorial   (C)
└─ 「用語を定義したい」                      → glossary   (C)
```

迷ったときの既定の倒し方:
- **decision か research か** → 「結論(やる/やらない)」が主なら `decision`、「調べた事実」が主なら `research`。両方あるなら decision を主、research を従にして相互リンク。
- **how-to か runbook か** → 誤実行の代償が大きい(本番・破壊的操作・復旧)なら `runbook`(TTL 短)。日常作業なら `how-to`。
- **reference か explanation か** → 「引く」なら `reference`、「なぜそうなっているか理解する」なら `explanation`。
- **how-to か tutorial か** → 既知の人が手順を実行するなら `how-to`、未習熟者を学ばせるなら `tutorial`。

**1ファイルに複数 type を混ぜない。** 混ざりそうなら分割し、相互リンクで繋ぐ。

---

## 調査・提案が決定に化けるとき（昇格の連鎖）

model A の記録(rfc / research)が後で decision に繋がる場合の扱い。**rfc と research で扱いが違う**ので注意。

### rfc → decision（supersede する）

`rfc` は提案段階の記録。**受理されたら提案としての役目は終わる**ので supersede する:

1. 対応する `decision` を **新規作成**(`supersedes` に rfc を指す)
2. `rfc` を `status: superseded` にし、`superseded_by` を decision へ向ける
3. rfc 本文のバナーを SUPERSEDED に書き換える

これで「提案 → 決定」の連鎖が監査可能に残る。rfc を削除しない。

### research → decision（supersede しない）

`research` は「その時点で何を調べ何が分かったか」の事実スナップショット。**決定が下っても調査事実は無効にならない**ので、research は **active のまま残し、supersede しない**。

1. 対応する `decision` を新規作成し、その `関連` から research へリンク(decision 側 `supersedes` は使わない)
2. research 側は active のまま。`関連` / `Open questions` に decision への相対リンクを追記する
3. research の本文・status は変えない(model A 不変)

判定の目安: 「役目が終わって置き換わる」=supersede(rfc)。「事実として残り続け、別の記録に参照される」=リンクのみ(research)。

### 未存在の後継への前方リンクは『曖昧参照』ではない

research / rfc が「決まったらここに decision を作って相互リンクする」と**明示的に予定リンクを書くのは規約違反ではない**。ベストプラクティスが禁じる「曖昧参照」は *どこを見ればよいか分からない* 濁した言及のこと。前方リンクは `Open questions` に置き、作成予定の相対パス(例: `../decision/<slug>.md`)まで具体的に書けば、意図が明確で監査可能になる。

---

## category（技術ドメイン）との関係

- `type` は **何の種類の知見か**(validity model を決める)。
- `category` は **どの技術ドメインか**(`nvim`/`omniwm`/`nix`/…、出力先 `docs/<category>/` を決める)。
- 両者は直交する。出力パスは `docs/<category>/<type>/<slug>.md` で両方を表現する。
- 同じ `category` に複数 type が同居してよい(例: `docs/nvim/decision/...` と `docs/nvim/runbook/...`)。

### 跨ドメインのとき(primary-domain rule)

1つの知見が複数ドメインに触れることは多い。category は1つに決める必要があるので、**「その知識を最も特定する固有制約があるドメイン」を primary に選ぶ**。

- 判定の問い: 「この知見が無くて一番困るのはどのドメインの作業か」「判断を縛っている固有の事実はどのドメイン由来か」。
- 例: 「Codex 0.128 は skill の symlink を辿らない」→ nix(配置)・claude(併用)にも関係するが、制約の発生源は Codex → `category: codex`。
- 「広く薄く関係する」ドメインを選ばない。残りのドメインの docs からは相互リンク(1階層)で辿れるようにする。
