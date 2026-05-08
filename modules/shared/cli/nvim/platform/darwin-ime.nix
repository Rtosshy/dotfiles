{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isDarwin {
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        options.silent = true;
        action.__raw = ''
          function()
            vim.system({ "macism", "com.apple.keylayout.ABC" })
          end
        '';
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      im-select-nvim
    ];

    extraConfigLuaPost = ''
      require("im_select").setup({
        default_command = "macism",
        set_previous_events = {},
      })
    '';
  };
}
