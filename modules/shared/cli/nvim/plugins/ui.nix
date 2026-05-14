{
  programs.nixvim = {
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "moon";
        transparent = true;

        styles = {
          sidebars = "transparent";
          floats = "transparent";
        };
      };
    };

    plugins = {
      web-devicons.enable = true;

      mini = {
        enable = true;
        modules.icons = { };
      };

      bufferline.enable = true;

      lualine = {
        enable = true;
        settings.options.theme = "tokyonight";
      };

      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>b";
            group = "buffer";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "diagnostics";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "help";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "line";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "save";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "window";
          }
          {
            __unkeyed-1 = "<leader>ws";
            group = "split";
          }
        ];
      };

      smear-cursor.enable = true;
      snacks.enable = true;
    };
  };
}
