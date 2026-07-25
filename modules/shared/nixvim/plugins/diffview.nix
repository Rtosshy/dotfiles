{ pkgs, ... }:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>gdo";
      action = "<cmd>DiffviewOpen<CR>";
      options = {
        silent = true;
        desc = "Git diff open";
      };
    }
    {
      mode = "n";
      key = "<leader>gdc";
      action = "<cmd>DiffviewClose<CR>";
      options = {
        silent = true;
        desc = "Git diff close";
      };
    }
    {
      mode = "n";
      key = "<leader>gdf";
      action = "<cmd>DiffviewFileHistory %<CR>";
      options = {
        silent = true;
        desc = "Git diff current file history";
      };
    }
    {
      mode = "n";
      key = "<leader>gdh";
      action = "<cmd>DiffviewFileHistory<CR>";
      options = {
        silent = true;
        desc = "Git diff repository history";
      };
    }
    {
      mode = "n";
      key = "<leader>gdr";
      action.__raw = ''
        function()
          if not vim.wo.diff then
            vim.notify("Git diff restore hunk is only available in diff mode", vim.log.levels.WARN)
            return
          end

          vim.cmd.diffget()
        end
      '';
      options = {
        silent = true;
        desc = "Git diff restore hunk";
      };
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    diffview-nvim
  ];

  extraConfigLuaPost = ''
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 35,
        },
      },
    })
  '';
}
