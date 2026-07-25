{
  colorschemes.cyberdream = {
    enable = true;
    lazyLoad = {
      enable = true;
    };

    settings = {
      transparent = true;

      styles = {
        sidebars = "transparent";
        floats = "transparent";
      };

      highlights = {
        FloatBorder.fg = "#ffffff";
        BlinkCmpMenuBorder.fg = "#ffffff";
        BlinkCmpDocBorder.fg = "#ffffff";
        BlinkCmpSignatureHelpBorder.fg = "#ffffff";
        TelescopeBorder.fg = "#ffffff";
      };
    };
  };

  plugins = {
    web-devicons.enable = true;

    bufferline.enable = true;

    lualine = {
      enable = true;
      settings = {
        options.theme = "cyberdream";
        # noice 有効時は native の "recording @x"(msg_showmode)が表示されないため、
        # 記録中レジスタを statusline に常時表示する
        sections.lualine_x = [
          {
            __unkeyed-1.__raw = ''
              function()
                local reg = vim.fn.reg_recording()
                return reg ~= "" and ("● REC @" .. reg) or ""
              end
            '';
            color.fg = "#ff6e5e";
          }
          "encoding"
          "fileformat"
          "filetype"
        ];
      };
    };

    which-key = {
      enable = true;
      # which-key は単一英字キーに自動トリガーを張らないため、
      # q は明示的にトリガー指定が必要(<auto> はデフォルト動作の維持)
      settings.triggers = [
        {
          __unkeyed-1 = "<auto>";
          mode = "nxso";
        }
        {
          __unkeyed-1 = "q";
          mode = "n";
        }
        {
          __unkeyed-1 = "@";
          mode = "n";
        }
      ];
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
          __unkeyed-1 = "<leader>gd";
          group = "git diff";
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
          # q をトリガーにして記録先レジスタを which-key で選ぶ。
          # expand の項目は rhs 関数必須(desc のみだと which-key が
          # サフィックス "a" だけを feed し、q が消えて記録が始まらない)。
          # 関数側で "q<reg>" を feed して Vim 標準の記録を開始する。
          # フラグの i は必須: qa に続けて一気に打った内容が typeahead に
          # 残っている場合、i なしだと記録開始がその後ろに回って順序が壊れる。
          # 記録中は which-key がトリガーを外すため停止の q も普通に効く。
          __unkeyed-1 = "q";
          mode = "n";
          group = "record macro";
          expand.__raw = ''
            function()
              local items = {}
              for i = string.byte("a"), string.byte("z") do
                local reg = string.char(i)
                local content = vim.fn.getreg(reg)
                items[#items + 1] = {
                  reg,
                  function()
                    vim.api.nvim_feedkeys("q" .. reg, "nit", false)
                  end,
                  desc = content == "" and "(empty)" or vim.fn.keytrans(content):sub(1, 40),
                }
              end
              return items
            end
          '';
        }
        {
          # @ も同様に which-key でレジスタを選んで再生する。
          # 空レジスタは再生しても no-op なので一覧から除外する。
          # カウント(3@a 等)は execute 時点でも vim.v.count に残っているので引き継ぐ。
          __unkeyed-1 = "@";
          mode = "n";
          group = "play macro";
          expand.__raw = ''
            function()
              local items = {}
              for i = string.byte("a"), string.byte("z") do
                local reg = string.char(i)
                local content = vim.fn.getreg(reg)
                if content ~= "" then
                  items[#items + 1] = {
                    reg,
                    function()
                      local count = vim.v.count > 0 and tostring(vim.v.count) or ""
                      vim.api.nvim_feedkeys(count .. "@" .. reg, "nit", false)
                    end,
                    desc = vim.fn.keytrans(content):sub(1, 40),
                  }
                end
              end
              return items
            end
          '';
        }
      ];
    };

    smear-cursor.enable = true;
  };

  # lualine の定期リフレッシュ(既定 1s)を待たず REC 表示を即時反映する
  autoCmd = [
    {
      event = "RecordingEnter";
      callback.__raw = ''
        function()
          require("lualine").refresh()
        end
      '';
    }
    {
      event = "RecordingLeave";
      # RecordingLeave 発火時点では reg_recording() がまだ空にならないため遅延させる
      callback.__raw = ''
        function()
          vim.defer_fn(function()
            require("lualine").refresh()
          end, 50)
        end
      '';
    }
  ];
}
