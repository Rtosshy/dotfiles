{
  pkgs,
  nvimx,
  ...
}:

let
  lockDir = ./nvim/nvimx-lock;

  languageServers = with pkgs; [
    lua-language-server
    pyright
    gopls
    kotlin-language-server
    terraform-ls
    rust-analyzer
    nixd
    haskell-language-server
    clang-tools
    vtsls
    astro-language-server
    # astro-ls fallback tsdk when the project has no usable local typescript.
    # TypeScript 7 (Go) lacks tsserverlibrary.js, so pin v5 here.
    typescript_5
    prettier
  ];

  treesitterGrammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
    astro
    bash
    c
    cpp
    css
    fish
    go
    haskell
    html
    javascript
    json
    lua
    nix
    rust
    terraform
    tsx
    typescript
    yaml
  ];

  nvimConfig = pkgs.runCommandLocal "nvimx-config" { } ''
    mkdir -p "$out"
    cp -R ${./nvim}/. "$out/"

    mkdir -p "$out/assets"
    ln -s ${../../../assets/frames} "$out/assets/frames"

    mkdir -p "$out/parser"
    ${pkgs.lib.concatMapStringsSep "\n" (
      grammar: ''ln -s ${grammar}/parser/*.so "$out/parser/"''
    ) treesitterGrammars}
  '';
in
{
  programs.nvimx = {
    enable = true;
    configDir = nvimConfig;
    inherit lockDir;
    extraPackages = languageServers;
    env = import ./env.nix {
      inherit
        pkgs
        nvimx
        lockDir
        ;
      extraPackages = languageServers;
    };

    lock = {
      projectDir = "~/ghq/github.com/Rtosshy/dotfiles";
      configDirRelative = "modules/shared/nvimx/nvim";
      lockDirRelative = "modules/shared/nvimx/nvim/nvimx-lock";
    };
  };
}
