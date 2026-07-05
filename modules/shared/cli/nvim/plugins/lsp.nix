{
  autoCmd = [
    {
      event = "LspAttach";
      callback.__raw = ''
        function(args)
          local opts = { buffer = args.buf, silent = true }
          local function lsp_map(key, action, desc)
            vim.keymap.set("n", key, action, vim.tbl_extend("force", opts, { desc = desc }))
          end

          lsp_map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "LSP definitions (Snacks)")
          lsp_map("gD", function()
            Snacks.picker.lsp_declarations()
          end, "LSP declarations (Snacks)")
          lsp_map("gri", function()
            Snacks.picker.lsp_implementations()
          end, "LSP implementations (Snacks)")
          lsp_map("grr", function()
            Snacks.picker.lsp_references()
          end, "LSP references (Snacks)")
          lsp_map("grt", function()
            Snacks.picker.lsp_type_definitions()
          end, "LSP type definitions (Snacks)")
          lsp_map("K", vim.lsp.buf.hover, "LSP hover")
          lsp_map("grn", vim.lsp.buf.rename, "LSP rename")
          lsp_map("gra", vim.lsp.buf.code_action, "LSP code action")
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
      key = "<leader>df";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "Open floating diagnostic message";
    }
    {
      mode = "n";
      key = "<leader>dl";
      action.__raw = "vim.diagnostic.setloclist";
      options.desc = "Open diagnostics list";
    }
  ];

  plugins.lsp = {
    enable = true;
    capabilities = ''
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
    '';
    servers = {
      lua_ls = {
        enable = true;
        settings.Lua.diagnostics.globals = [ "vim" ];
      };
      pyright.enable = true;
      gopls.enable = true;
      kotlin_language_server = {
        enable = true;
        # kotlin-language-server expects initializationOptions to be a JSON
        # object. An empty init_options is encoded by Neovim as `[]` (array),
        # which makes the server crash in getStoragePath during initialize.
        # Providing a real storagePath keeps it a `{}` object.
        extraOptions.init_options.storagePath.__raw = ''vim.fn.stdpath("cache") .. "/kotlin-language-server"'';
      };
      terraformls.enable = true;
      rust_analyzer = {
        enable = true;
        installRustc = false;
        installCargo = false;
        settings = {
          check.command = "clippy";
          cargo.allFeatures = true;
        };
      };
      nixd.enable = true;
    };
  };

  extraConfigLuaPost = ''
    vim.diagnostic.config({
      virtual_text = { prefix = "" },
      severity_sort = true,
      float = { source = true },
    })
  '';
}
