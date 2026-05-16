# skills

複数の AI コーディング CLI ランタイムで共有するメンタリング系 skill 群。1 ファイルの SKILL.md を Nix から Claude Code / Codex CLI の両方にデプロイする。

## 配置(home-manager 経由)

| ランタイム | デプロイ先 | 配置元 | デプロイ方法 |
|---|---|---|---|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` | `claude/default.nix` | `home.file` の symlink |
| Codex CLI 0.128.0 | `~/.codex/skills/<name>/SKILL.md` | `codex/default.nix` | **`home.activation` で実ファイル cp** |

両方とも `modules/shared/cli/skills/<name>/SKILL.md` を配置元として使う。

### なぜ Codex だけ実ファイルにするか

Codex CLI 0.128.0 は **skill ディスカバリで symlink を辿らない**。home-manager のデフォルトの symlink デプロイだとロードされない(エラーも出さず黙って skip)。実測で確認:

- symlink 配置 → skill リストに出てこない
- 同内容の実ファイル → skill リストに出る

そのため `codex/default.nix` だけ `home.activation` で `install -Dm644` する形に。Claude Code は symlink を正しく辿るので `home.file` のままで OK。

## ランタイム間の互換性

### 起動方法

| ランタイム | 起動構文 |
|---|---|
| Claude Code | `/skill-name` |
| Codex CLI | `$skill-name`(または `/skills` でリスト表示) |
| GitHub Copilot CLI | プロンプト内で `/skill-name`(参考。本リポは未デプロイ) |

### 各 SKILL.md は両ランタイムから読まれる前提で書く

- **`description` フィールド**: 両形式併記
  - 例: `\`/design-coach\`(Claude) または \`$design-coach\`(Codex) で起動する`
- **本文中の他 skill 参照**: 中立表記 `\`scope-coach\` skill`
  - 理由: エージェントがユーザーに伝える文面。ユーザーは自分のランタイムの構文を補う
- **`allowed-tools` フィールド**: **YAML リスト形式**(必須)
  - Claude 公式は「space 区切り or YAML リスト」
  - Codex の YAML パーサーはカンマ区切りで `Bash(git log:*)` のようなコロン入り値を含むと破綻する
  - YAML リスト形式が両方で確実に動く唯一の表現

```yaml
allowed-tools:
  - Read
  - Grep
  - Bash(git log:*)   # コロン入りでも個別スカラなので安全
```

## 検証ベース

`codex exec 'List all skills currently available to you'` で実測。Claude 側は本ツール群が常時ロードされていることで確認。

### 確認したこと

- Codex CLI 0.128.0 のユーザー skill ディスカバリパスは `~/.codex/skills/`(公式 docs の `~/.agents/skills/` は新版仕様で 0.128.0 未対応)
- Codex は frontmatter の `allowed-tools` を **カンマ区切り + paren** で書くと「missing YAML frontmatter」と誤導的なエラーで skill 自体を skip する
- YAML リスト形式 (`- Read` を改行で並べる) は Codex / Claude 両方が受理
- `allowed-tools` の値の粒度は Claude / Codex で違うが、両方が知らない値は無視する模様

### 未確認

- Codex の新版で `~/.agents/skills/` 配置が動くか
- Copilot CLI で同 SKILL.md が動くか(spec 上は `~/.copilot/skills/` または `~/.agents/skills/` のどちらかに置けば良い)

## Copilot CLI 参考情報(未デプロイ)

`docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills` より:

- **personal skill パス**: `~/.copilot/skills/` または `~/.agents/skills/`
- **project skill パス**: `.github/skills`, `.claude/skills`, `.agents/skills`(リポ配下)
- **frontmatter 必須**: `name`, `description`(任意: `license`, `allowed-tools`)
- **`allowed-tools` の値が独自**: Claude/Codex の `Read`, `Bash(...)` 等ではなく `shell`, `bash` のような粗い粒度

→ 本リポの SKILL.md をそのまま Copilot にデプロイすると `allowed-tools` の値は無視されるが、skill 本体は動くはず(未実測)。デプロイするなら `copilot/default.nix` を `~/.copilot/skills/` 宛で作る。symlink を辿るかは未確認なので、Codex と同じく `home.activation` 経由が安全策。

## 発見の経緯と落とし穴(0.128.0 時点の検証ログ)

未来の自分(または Codex/Copilot アップグレード時)のためのメモ:

### 1. ディスカバリパス
- 公式 docs (developers.openai.com/codex/skills) は `~/.agents/skills/` と明記
- が、0.128.0 では未対応。`~/.codex/skills/` に置く必要がある
- changelog にもパス変更の明示なし。新版で `~/.agents/skills/` に対応した可能性はあるので、アップグレード時は `codex exec 'list skills'` で再実測すること

### 2. frontmatter の YAML パース
- 0.128.0 の `allowed-tools` を `Read, Grep, Bash(git log:*)` のようにカンマ区切り + paren で書くと YAML パース失敗
- エラーメッセージは「missing YAML frontmatter delimited by ---」と誤導的だが、実際の原因は値内の `:` と `(` の解釈失敗
- **YAML リスト形式に揃えれば** Claude 公式準拠かつ Codex で動く ← 本リポはこの形式

### 3. symlink を辿らない
- 0.128.0 の skill ディスカバリは `~/.codex/skills/<name>/SKILL.md` が **symlink だと無視する**(エラーも出さず silently skip)
- home-manager のデフォルト(`home.file` の `source`)は symlink デプロイなので、放置するとロードされない
- 回避策: `home.activation` で `install -Dm644` で実ファイル cp
- Claude Code は symlink を辿るのでそのまま OK

### 4. 検証コマンド
```sh
codex exec --skip-git-repo-check 'List all skills currently available to you. Just print the names, one per line.'
```
非対話で skill リストが取れる。バージョン違いの挙動確認に使える。

## ランタイム追加手順(将来用)

新しいランタイムを足したくなったら:

1. `modules/shared/cli/<runtime>/default.nix` を作る
2. デプロイ先パスにシンボリックリンクを張る(ランタイムが symlink を辿るなら `home.file` の `source` で OK。辿らないなら Codex 同様 `home.activation` + `install -Dm644` で実ファイル化)
3. `modules/shared/cli/default.nix` でその `<runtime>` モジュールを import

SKILL.md 本体は基本変更不要(両形式併記・中立表記・YAML リスト `allowed-tools` で書かれているため)。

ただし以下が必要になる可能性あり:
- `allowed-tools` の値の粒度がそのランタイム独自なら、後付けで別管理(あるいは無視され続けることを許容)
- 起動構文が `/` / `$` 以外なら description の併記を3形式以上に増やす
