---
title: nixvimのlua_ls.settingsは自動でLuaにラップされる(二重ネストで型スタブが無効化した件)
id: nix-lua-ls-settings-wrap-0001
type: research
category: nix
status: active
created: 2026-07-07
valid_as_of: 2026-07-07
owner: "@Rtosshy"
tags: [nixvim, lua_ls, lsp, settings, wezterm-types, debugging]
---

<!-- 出力先: docs/nix/research/nixvim-lua-ls-settings-double-wrap.md -->

> ✅ **ACTIVE（有効・2026-07-07 時点）** — これは点時刻の記録です。以降の状況変化はこの記録を無効化しません。最新の決定は後継チェーンを辿ってください。

# nixvimのlua_ls.settingsは自動でLuaにラップされる(二重ネストで型スタブが無効化した件)

## 問い / Question

`wezterm-types` の型スタブを `lua_ls` の `workspace.library` に追加し、`---@type Wezterm` アノテーションも修正したのに、なぜ `Wezterm` 型が一切認識されず(`undefined-doc-name`)、`wezterm.on` / `log_info` / `time` / `config_builder` など `wezterm.*` へのアクセスが軒並み `undefined-field` になったのか。

## 結論 / Findings

nixvim の `lua_ls`(および `nixd`, `nil_ls`, `omnisharp` など一部サーバー)は、`plugins.lsp.servers.<name>.settings` を**サーバー固有のキーで自動的に一段ラップする**実装になっている。

```nix
# nixvim: plugins/lsp/language-servers/default.nix
lua_ls = {
  settings = cfg: { Lua = cfg; };
};
nixd = {
  settings = cfg: { nixd = cfg; };
};
nil_ls = {
  settings = cfg: { nil = cfg; };
};
```

このため、ユーザー側の nix 設定で

```nix
lua_ls.settings.Lua = {
  workspace.library = [ "${wezterm-types}" ];
  diagnostics.globals = [ "vim" ];
};
```

のように**自分でもう一段 `.Lua` を書くと、実際に生成される設定が `settings.Lua.Lua.*` と二重にネストされる**。lua-language-server は `settings.Lua.*` しか見ないため、二重ネストされた中身は静かに無視され、`workspace.library` は事実上空のまま(`diagnostics.globals = ["vim"]` も同様に効いていなかったが、`vim` グローバルは別経路でも認識されることが多く症状が目立たなかった)。

**この失敗は `nix build`/rebuild では一切検知できない。** `settings` は `attrsOf anything`(自由形式)で型チェックが効かないため、ビルドは通り、生成された `init.lua` にもそれらしい値が書き込まれる。壊れているのは実行時の意味論だけで、生成された設定を実際にLSPクライアントへ読み込ませて確認する以外に不整合を検出する方法がなかった。

修正: `settings.Lua = {...}` ではなく `settings = {...}`(素の値をそのまま渡す。nixvim側が自動で `Lua` にラップしてくれる)。

## 試したこと・観測 / What was tried

- 症状: `---@type Wezterm` アノテーション修正後も3ファイル全てで `Undefined type or alias 'Wezterm'.`(`undefined-doc-name`)が発生し、`wezterm.*` へのアクセスが軒並み `undefined-field`。
- 生成された実設定を直接確認:
  ```sh
  readlink -f ~/.config/nvim/init.lua
  grep -n "lua_ls" <resolved-path>
  ```
  → `settings = { Lua = { Lua = { diagnostics = {...}, workspace = { library = {...} } } } }` という二重ネストを確認。フェッチした `wezterm-types` の store path 自体は正しく存在し、中身も正常だった(パス自体は無罪)。
- headless nvim で実際のLSPクライアントの状態を実測(推測で終わらせない):
  ```lua
  -- yoshi-error.lua を開き、lua_ls client の
  -- config.settings.Lua.workspace.library を確認 → nil
  -- workspace/symbol リクエストで "Wezterm" を検索
  -- → ヒットは3ファイル内のローカル変数 wezterm (kind=13=Variable) のみ。
  --   型スタブ側の `Wezterm` クラス定義は一切インデックスされていなかった。
  ```
- nixvim のソースを直接確認して原因を特定:
  ```sh
  curl -s https://raw.githubusercontent.com/nix-community/nixvim/main/plugins/lsp/language-servers/default.nix \
    | grep -n -A2 "lua_ls"
  # lua_ls = { settings = cfg: { Lua = cfg; }; };
  ```
  同ファイル内の汎用コンストラクタ `_mk-lsp.nix` で、この `settings` 引数(サーバーごとに上書き可能な変換関数、既定は恒等関数 `cfg: cfg`)が `cfg.settings`(ユーザー入力)に適用されてから最終的な `vim.lsp.config(...)` に渡されることを確認。
- 修正(`settings.Lua = {...}` → `settings = {...}`)を適用。rebuild + nvim再起動後の再検証は本記録の時点では未実施(下記Open questions参照)。

## 根拠・出典 / Evidence

- nixvim ソース(サーバー別ラップ定義): https://github.com/nix-community/nixvim/blob/main/plugins/lsp/language-servers/default.nix
- nixvim 汎用サーバー構築ヘルパー(`settings` 変換の適用箇所): https://github.com/nix-community/nixvim/blob/main/plugins/lsp/language-servers/_mk-lsp.nix
- リポジトリ内、修正箇所: [lsp.nix](../../../modules/shared/nvim/plugins/lsp.nix)
- 生成物: `~/.config/nvim/init.lua`(home-manager が `~/.config/nvim/init.lua` に symlink する生成ファイル)
- Neovim公式ヘルプ(`:help lsp-quickstart`、オンライン版): https://neovim.io/doc/user/lsp/ — `lua_ls` の `settings = { Lua = {...} }` 例が載っている箇所。ただしこれは生の `vim.lsp.config()` 向けの例であり、nixvimの `settings` オプションとは層が異なる点に注意

## 考慮・トレードオフ / Considerations

- **公式ドキュメントは間違っていなかった、というのが一番の教訓。** Neovim公式の `:help lsp-quickstart` には `lua_ls` の設定例として、まさに以下がそのまま載っている。

  ```lua
  vim.lsp.config('lua_ls', {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".git" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
      },
    },
  })
  ```

  これは **`vim.lsp.config()` に直接渡す最終形としては完全に正しい**(公式Helpも「settingsはサーバー固有なので、サーバー側のドキュメントを見ろ」と明記している)。だが nixvim の `plugins.lsp.servers.lua_ls.settings` は、この最終形そのものではなく **nixvim が独自に `Lua` を一段追加する前の"手前の値"** だった。「どのレイヤーの話をしているドキュメントか」を区別せずに、公式の最終形の例をそのまま nixvim の `settings` オプションに持ち込んだことが、二重ネストの直接の引き金だった。教訓としては、「複数の抽象化層を跨ぐときは、その公式ドキュメントが説明しているのがどの層の入出力なのかを常に確認する」。
- nixvim の公式オプション検索ページ(`plugins.lsp.servers.lua_ls.settings`)は**全サーバー共通の汎用オプション**として表示され、Declarations リンクも汎用の `default.nix` を指すのみ。**サーバー固有のラップ変換はオプションドキュメントには一切現れない。** 実際のサーバー定義一覧(同名 `default.nix` 内の生成テーブル部分)を直接読むまで到達できなかった。
- 「rebuildが通る = 設定は正しい」という思い込みが調査を遅らせた。`attrsOf anything` 系オプションは Nix の型システムの保護範囲外であり、生成された実体を見るか実際に LSP を動かして確認するまで正誤を判定できない。

## 次アクション / Open questions

- 修正後(`settings = {...}` へ変更、rebuild + nvim再起動後)に、同じ headless nvim 検証(`workspace/symbol` で `Wezterm` の Class 定義がヒットするか)で再確認する。
- 再発防止策(生成物を確認する習慣化、smoke-testスクリプトの整備、`lsp.nix` への注意コメント追加など)をどう仕組み化するかは検討中。方針が決まったら `../decision/nixvim-lsp-settings-verification.md`(仮)を作成し、ここから相互リンクする。

## 関連

- [lsp.nix](../../../modules/shared/nvim/plugins/lsp.nix) — 実際に修正した設定ファイル
- [lazy-load-plugin-with-lz-n.md](../../nvim/how-to/lazy-load-plugin-with-lz-n.md) — 同じく「ビルドは通るが実行時の検証が別途必要」という教訓を持つ関連ナレッジ

<!--
ある時点のスナップショット。後で状況が変わってもこの記録は編集しない。
この research が decision に繋がっても research は active のまま(supersede しない)。
decision 側の「関連」からここへリンクする。詳細は reference/knowledge-types.md「昇格の連鎖」。
-->
