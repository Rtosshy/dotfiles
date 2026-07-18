---
title: nixvim プラグインを lz.n で安全に lazy 化する
id: nvim-lazy-load-0001
type: how-to
category: nvim
status: active
created: 2026-06-21
last_reviewed: 2026-06-21
review_due: 2026-12-18
owner: "@Rtosshy"
tags: [nixvim, lz-n, lazy-loading, lua, performance]
---

<!-- 出力先: docs/nvim/how-to/lazy-load-plugin-with-lz-n.md -->

> ✅ **ACTIVE（有効）** — 最終レビュー: 2026-06-21 ／ 次回レビュー期限: 2026-12-18

# nixvim プラグインを lz.n で安全に lazy 化する

## 要約

nixvim の lazy loading は **lz.n プロバイダ依存**(現状唯一)。`plugins.<name>.lazyLoad.settings` に lz.n の spec(`cmd`/`keys`/`event`/`ft`)を書くと、その plugin は opt 化されトリガーまでロードされない。**最大の罠は、`require('plugin')` を直叩きしている呼び出し箇所が `cmd` トリガーをすり抜けてロード前にエラーになること**。lazy 化前に全呼び出し箇所を grep し、コマンド形式へ変換する。

## 前提

- `plugins.lz-n.enable = true;` が必須。プロバイダ無しで `lazyLoad.enable` するとビルド時 assertion で弾かれる(静かに無視はされない)。
- `lazyLoad.settings` は lz.n の plugin spec にそのまま渡る。nixvim が `after`(= setup 呼び出し)を自動生成する。

## 手順

1. **トリガーを決める。** 起動時に不要で、コマンド/キー駆動のものが第一候補。
   - 全キーマップが `<cmd>X ...>` 経由 → `cmd = [ "X" ]` だけで足りる(例: trouble, lazygit)。
   - プラグインが複数コマンドを提供 → cold 実行に備えて**全コマンドを列挙**(例: lazygit の6コマンド)。

2. **`require` 直叩きの呼び出し箇所を grep する。**
   ```
   grep -rn "PluginName\|require('module')" modules/shared/nvim
   ```
   `<cmd>lua require('telescope.builtin')...>` のような直叩きは `cmd` トリガーを発火させない。
   - **コマンド化できるもの** → `<cmd>Telescope find_files<cr>` 等に変換(alpha のダッシュボードボタン、devdocs の picker がこれだった)。
   - **コマンド化できないもの**(関数引数を渡す等。例: `live_grep({ additional_args = ... })`)→ `keys` トリガーに移し、キー押下でロードを発火させる。

3. **`keys` トリガーの形式に注意。** lz.n は positional `[1]=lhs, [2]=rhs`。nixvim では `__unkeyed-*`(接頭辞が同じものはアルファベット順で positional 出力)で表現する:
   ```nix
   keys = [
     {
       __unkeyed-1 = "<leader>fl";          # lhs → [1]
       __unkeyed-2 = "<cmd>...<CR>";         # rhs → [2]
       mode = "n";
       silent = true;
       desc = "...";
     }
   ];
   ```
   `keys` に移したキーは `keymaps = [...]` 側から**削除**する(二重定義を避ける)。

4. **ビルドで検証する**(下記)。

## 検証コマンド

システム全体を switch せず、nvim パッケージ単体をビルドして init 生成と assertion を確認できる:

```
nix build --no-link --print-out-paths \
  ".#darwinConfigurations.MacBook-V3.config.home-manager.users.tosshy.programs.nixvim.build.package"
```

- `packdir-opt` が生成されれば lazy 振り分けが効いている証拠。
- 生成された `init.lua` を `grep -n 'lz.n").load'` で開き、各 plugin の `cmd`/`keys`/`after` が期待通りか確認する。特に `keys` が `{ "<lhs>", "<rhs>", ... }` の順になっているか。
- ビルド成功は設定の妥当性までしか保証しない。**実際のキー押下によるランタイム挙動は `switch` 後に手で確認する**(起動が速くなったか・全機能が動くか)。

## Why（なぜこの手順か）

- lz.n は `require` をフックしない。opt 化された plugin は trigger まで runtimepath に入らないため、ロード前の `require('plugin.module')` は「module not found」または未 setup 状態になる。だから「全 require 呼び出し箇所をコマンド/keys 経由に寄せる」のが核心。
- コマンド形式への統一は、lz.n のプラグイン登録名(`trigger_load` の引数)を推測せずに済むぶん安全で、既存キーマップの書き方とも一致する。

## 関連

- [telescope.nix](../../../modules/shared/nvim/plugins/telescope.nix) — cmd + keys 併用の実例
- [lazygit.nix](../../../modules/shared/nvim/plugins/lazygit.nix) — 全コマンド列挙の実例
- [alpha.nix](../../../modules/shared/nvim/plugins/alpha.nix) / [devdocs.nix](../../../modules/shared/nvim/plugins/devdocs.nix) — require 直叩きをコマンド化した呼び出し箇所
- nixvim 公式テスト: `tests/test-sources/plugins/lazyloading/lz-n.nix`(`lazyLoad.settings.cmd/keys` の正準例)
