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

    extraConfigLuaPost = ''
      local function set_transparent_number_highlights()
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#7aa2f7", bg = "NONE" })
        vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#7aa2f7", bg = "NONE" })
        vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#7aa2f7", bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Whitespace", { fg = "#6b729c", bg = "NONE" })
        vim.api.nvim_set_hl(0, "NonText", { fg = "#6b729c", bg = "NONE" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "tokyonight*",
        callback = set_transparent_number_highlights,
      })

      set_transparent_number_highlights()
    '';

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
      snacks = {
        enable = true;
        settings.picker.enabled = true;
      };
    };
  };
}
