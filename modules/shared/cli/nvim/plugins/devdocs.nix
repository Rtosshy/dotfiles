{ pkgs, ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>ho";
        action = "<cmd>DevDocs get<cr>";
        options = {
          silent = true;
          desc = "Open DevDocs";
        };
      }
      {
        mode = "n";
        key = "<leader>hi";
        action = "<cmd>DevDocs install<cr>";
        options = {
          silent = true;
          desc = "Install DevDocs";
        };
      }
      {
        mode = "n";
        key = "<leader>hv";
        action.__raw = ''
          function()
            if not _G.setup_devdocs() then
              return
            end

            local devdocs = require("devdocs")
            local installed_docs = devdocs.GetInstalledDocs()
            vim.ui.select(installed_docs, {}, function(selected)
              if not selected then
                return
              end

              local doc_dir = devdocs.GetDocDir(selected)
              require("telescope.builtin").find_files({ cwd = doc_dir })
            end)
          end
        '';
        options.desc = "View DevDocs";
      }
      {
        mode = "n";
        key = "<leader>hd";
        action = "<cmd>DevDocs delete<cr>";
        options = {
          silent = true;
          desc = "Delete DevDocs";
        };
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      devdocs-nvim
    ];

    extraConfigLuaPost = ''
      local devdocs_configured = false
      function _G.setup_devdocs()
        if devdocs_configured then
          return true
        end

        vim.fn.mkdir(vim.fn.stdpath("data") .. "/devdocs", "p")
        pcall(vim.api.nvim_del_user_command, "DevDocs")

        local ok, devdocs = pcall(require, "devdocs")
        if not ok then
          vim.notify("Failed to load devdocs.nvim", vim.log.levels.ERROR)
          return false
        end

        devdocs.setup({
          ensure_installed = {
            "go",
            "html",
            "http",
            "lua~5.1",
          },
        })
        devdocs_configured = true
        return true
      end

      vim.api.nvim_create_user_command("DevDocs", function(opts)
        if _G.setup_devdocs() then
          vim.cmd.DevDocs(opts.args)
        end
      end, { nargs = "*" })
    '';
  };
}
