{ lib, pkgs, ... }:

let
  # 意図した設定だけを持つ層。base.toml に存在しないキーを書くと
  # merge.py が非ゼロ終了し、ビルドごと失敗する。OmniWM のキー改名を
  # 「静かな設定消失」ではなくビルドエラーとして検知するための仕掛け。
  overridesJSON = pkgs.writeText "omniwm-overrides.json" (builtins.toJSON (import ./overrides.nix));

  # base.toml は再シリアライズしない。値だけを行単位で差し替えるので、
  # 触れていない行はバイト単位で保たれ、float/integer の区別も壊れない。
  # OmniWM 0.6.3 以降は型不正もファイル全体を無効化するため、これは必須。
  # 理由: docs/omniwm/decision/settings-toml-sync-model.md
  settingsFile = pkgs.runCommand "omniwm-settings.toml" { } ''
    ${pkgs.python3}/bin/python3 ${./merge.py} \
      --base ${./base.toml} \
      --overrides ${overridesJSON} \
      --out $out
  '';
in
{
  # OmniWM rewrites settings.toml after loading it, so deploy it as a real
  # writable file instead of a Home Manager symlink to the Nix store.
  home.activation.materializeOmniWMSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -Dm644 ${settingsFile} $HOME/.config/omniwm/settings.toml
  '';
}
