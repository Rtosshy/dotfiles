---
title: darwin システムの CI ビルドを renovate/* ブランチに限定する
id: nix-ci-darwin-build-0001
type: decision
category: nix
status: active
created: 2026-11-06
valid_as_of: 2026-11-06
owner: "@Rtosshy"
tags: [nix, ci, github-actions, nix-darwin, renovate, flake-lock]
---

<!-- 出力先: docs/nix/decision/ci-darwin-build-renovate-only.md -->

> ✅ **ACTIVE（有効・2026-11-06 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# darwin システムの CI ビルドを renovate/* ブランチに限定する

## 状況 / Context

Renovate の flake.lock 更新 PR (#37) が CI を通過したのに、ローカルの `darwin-rebuild switch` は `nss-cacert` のビルドで失敗した。

- 原因: NSS 3.131.1 で `emSign ECC Root CA - G3` が certdata から削除された。一方、自前の `security.pki.caCertificateBlacklist` はこれを無条件で指定していた。buildcatrust は、ストアに存在しないブロックリスト名を見つけると exit 3 で失敗する。修正はコミット `7c24fff`。
- CI がこれを検出できなかった理由:
  - `ci.yaml` のジョブは `ubuntu-latest` 上の `nix flake check` だけ。
  - `nix flake check` は `darwinConfigurations` を評価するだけで、ビルドはしない。
  - x86_64-linux のランナーでは aarch64-darwin をそもそもビルドできない(ログに `The check omitted these incompatible systems: aarch64-darwin` と出る)。
  - 評価は通り、ビルドで初めて落ちる種類の失敗は、構造上 CI の検出範囲外だった。

## 決定 / Decision

`ci.yaml` に macOS ランナーで `darwinConfigurations."MacBook-V3".system` を実ビルドするジョブ `darwin-build` を追加する。実行は `startsWith(github.head_ref, 'renovate/')` の PR に限定する。

## 理由 / Rationale（Why）

- 評価は通るのにビルドで落ちる、という種類の破損は、主に依存の更新、つまり nixpkgs や nix-darwin の rev が変わったときに起きる。その変更を運ぶのは Renovate のブランチなので、検査をそこに集中させれば十分な効果が得られる。
- 時間の大半はキャッシュからのダウンロードで、変更内容とは関係なく毎回発生する。見積もりの根拠となる計測(2026-11-06 時点):
  - システムの closure は 235 パス / 2.2GB(展開後)。
  - そのうち cache.nixos.org にないのは 58 パスで、すべて `etc-*`・`launchd`・`Brewfile` などの軽量な生成物。
  - 見積もりは 3〜5 分/回。既存ジョブは 26〜50 秒。
  - 普段の PR すべてに 3〜5 分を足す価値はない。
- リポジトリは public なので、macOS ランナーは無料。費用は判断材料にならず、決め手は待ち時間だけだった。

## 検討した選択肢 / Options

| 選択肢 | 利点 | 欠点 | 不採用理由 |
| --- | --- | --- | --- |
| renovate/* の PR に限定して macOS でビルド | 依存更新の破損を検出し、普段の CI は約 40 秒のまま | 手動の flake 更新やモジュール変更によるビルド破損は検出できない | （採用） |
| 全 PR と main への push で macOS ビルド | ビルド破損をすべて検出できる | 毎回 3〜5 分かかり、大半がダウンロード | 待ち時間に対して効果が小さい |
| `flake.lock` 変更時(paths フィルタ)に限定 | 手動の flake 更新も対象になる | paths フィルタはジョブ単位で使えず、ワークフローの分割が必要 | 構成が複雑になる。定期的な flake 更新は Renovate が担う |
| 現状維持(評価のみ) | 追加コストなし | 今回の種類の失敗を検出できない | 実害が出たので不可 |

## トレードオフ・帰結 / Consequences

- 得たもの: Renovate PR のマージ前に、darwin システムがビルドできることを保証できる。
- 諦めたもの: Renovate 以外のブランチでの darwin ビルド破損は、引き続き手元の `darwin-rebuild` でしか分からない。
- Hydra が darwin 向けのビルドを終える前に Renovate PR が作られると、キャッシュミスでソースからのビルドが走り、数十分以上かかることがある。その場合は時間を置いて再実行する。
- home-manager の `homeConfigurations` は対象外。ここでビルド破損が問題になれば、同じ方針でジョブを足して再評価する。
- Renovate のブランチに手動でコミットすると、Renovate はそのブランチを更新しなくなる(#37 で実際に発生)。CI で落ちた PR を手で直すときは、この挙動を前提にする。

## 関連

- [`.github/workflows/ci.yaml`](../../../.github/workflows/ci.yaml)
- [`modules/darwin/nix-darwin/system/default.nix`](../../../modules/darwin/nix-darwin/system/default.nix)(修正コミット `7c24fff`)
- nix-darwin `97fd090` "security.pki: handle emSign roots removed in cacert 3.131.1"
