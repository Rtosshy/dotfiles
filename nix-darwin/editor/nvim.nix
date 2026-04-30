{ inputs, ... }: {
  imports = [ inputs.nixvim.homeModules.nixvim ];

  # 段階移行中: nixvim は有効化のみ、プラグイン定義は既存の lazy.nvim 設定をそのまま読み込む。
  # 各プラグインを nixvim DSL に移し終えたら extraConfigLuaPre と nvim/ ディレクトリを削除する。
  programs.nixvim = {
    enable = true;

    extraConfigLuaPre = ''
      local nvim_dir = "${../../nvim}"
      vim.opt.runtimepath:prepend(nvim_dir)
      package.path = nvim_dir .. "/lua/?.lua;" .. nvim_dir .. "/lua/?/init.lua;" .. package.path
      dofile(nvim_dir .. "/init.lua")
    '';

    plugins.im-select = {
      enable = true;
      settings = {
        default_command = "macism";
        set_previous_events = [ ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        action.__raw = ''
          function()
            vim.system({ 'macism', 'com.apple.keylayout.ABC' })
          end
        '';
      }
    ];
  };
}

