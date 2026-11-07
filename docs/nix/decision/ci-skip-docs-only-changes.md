---
title: CI はドキュメントのみの変更で走らせない(paths-ignore 方式)
id: nix-ci-paths-ignore-0002
type: decision
category: nix
status: active
created: 2026-11-06
valid_as_of: 2026-11-06
owner: "@Rtosshy"
tags: [nix, ci, github-actions, paths-ignore]
---

<!-- 出力先: docs/nix/decision/ci-skip-docs-only-changes.md -->

> ✅ **ACTIVE（有効・2026-11-06 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# CI はドキュメントのみの変更で走らせない(paths-ignore 方式)

## 状況 / Context

`ci.yaml` はすべての PR と、main への push のたびに `nix flake check` と lefthook を実行していた。PR #38 は ci.yaml とドキュメントの変更だったが、`docs/` だけを変える PR でも同じように CI が走る。

一方で、flake は `.nix` 以外のファイルも読み込んでいる。2026-11-06 時点で Nix から参照しているもの:

- `modules/shared/skills/*/SKILL.md`
- `app.toml`・`config.toml`・`btop.conf` などの設定ファイル
- `./config` などのディレクトリ
- `assets/frames`

lefthook は `*.lua` も検査する(stylua)。

## 決定 / Decision

`pull_request` と `push` の両方に `paths-ignore` を付け、`docs/**`・`**/README.md`・`.claude/**`・`.codex/**` だけで構成される変更では CI を走らせない。

## 理由 / Rationale（Why）

- 「`.nix` が変わったときだけ走らせる」許可リスト(`paths`)にすると、Nix から参照している非 Nix ファイルの変更を見逃す。例えば SKILL.md のリネームや TOML の削除は評価エラーになるが、CI は走らない。
- 除外リストに入れるのは、どの Nix コードからも読まれていないと確認したものだけにした。
  - `docs/` と各 README はコメント内で言及されているだけ。
  - `.claude/` と `.codex/` は、このリポジトリで作業するエージェント用のプロジェクト設定。
- 除外リストを外れたファイルは、何であれ CI が走る側に倒れる。漏れたときの害は「余分に CI が走る」だけで済む。
- main の ruleset(`main_rule`)には必須ステータスチェックがない。そのため、CI がスキップされた PR がマージ待ちで止まる問題は起きない。

## 検討した選択肢 / Options

| 選択肢 | 利点 | 欠点 | 不採用理由 |
| --- | --- | --- | --- |
| `paths-ignore` で明確に無関係なものを除外 | 見逃しが起きない側に倒れる | 新しい無関係なディレクトリは手で追加が必要 | （採用） |
| `paths` で `*.nix`・`flake.lock`・`*.lua` などを許可 | 意図が分かりやすい | Nix が読む非 Nix ファイルの変更を見逃す。参照が増えるたびに更新が必要 | 漏れたときに破損を見逃す |
| `**/*.md` を一括除外 | 設定が短い | SKILL.md は Nix から参照されている | 見逃しが起きる |
| 現状維持 | 設定不要 | ドキュメントだけの PR でも約 40 秒の CI が走る | 無駄な実行が残る |

## トレードオフ・帰結 / Consequences

- ドキュメントだけの PR では、CI のチェックが表示されなくなる(スキップではなく、ワークフロー自体が起動しない)。
- 将来 main の ruleset に CI を必須チェックとして加えると、ドキュメントだけの PR がマージできなくなる。その場合はこの決定を見直す。
- Nix から `docs/` や README を読み込むようにした場合は、除外リストから外す必要がある。
- `darwin-build` ジョブ([ci-darwin-build-renovate-only.md](./ci-darwin-build-renovate-only.md))も同じトリガーの下にあるので、ドキュメントだけの Renovate PR では動かない。Renovate はドキュメントを変更しないので影響はない。

## 関連

- [`.github/workflows/ci.yaml`](../../../.github/workflows/ci.yaml)
- [ci-darwin-build-renovate-only.md](./ci-darwin-build-renovate-only.md)
