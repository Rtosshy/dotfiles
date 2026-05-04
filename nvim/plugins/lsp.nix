{
  programs.nixvim = {
    autoCmd = [
      {
        event = "LspAttach";
        callback.__raw = ''
          function(args)
            local opts = { buffer = args.buf, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          end
        '';
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "[d";
        action.__raw = ''
          function()
            vim.diagnostic.jump({ count = -1, float = true })
          end
        '';
        options.desc = "Go to previous diagnostic message";
      }
      {
        mode = "n";
        key = "]d";
        action.__raw = ''
          function()
            vim.diagnostic.jump({ count = 1, float = true })
          end
        '';
        options.desc = "Go to next diagnostic message";
      }
      {
        mode = "n";
        key = "<leader>d";
        action.__raw = "vim.diagnostic.open_float";
        options.desc = "Open floating diagnostic message";
      }
      {
        mode = "n";
        key = "<leader>q";
        action.__raw = "vim.diagnostic.setloclist";
        options.desc = "Open diagnostics list";
      }
    ];

    plugins.lsp = {
      enable = true;
      servers = {
        lua_ls = {
          enable = true;
          settings.Lua.diagnostics.globals = [ "vim" ];
        };
        gopls.enable = true;
      };
    };

    extraConfigLuaPost = ''
      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        severity_sort = true,
        float = { source = true },
      })
    '';
  };
}
