_: {
  # パーサーとクエリファイルは lazy.nvim 経由で nvim-treesitter が管理する。
  # programs.neovim.plugins で入れると lazy.nvim の runtimepath 管理と競合するため、
  # Nix 側ではプラグイン管理をしない。
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };

  xdg.configFile."nvim" = {
    source = ../../nvim;
    recursive = true;
  };
}
