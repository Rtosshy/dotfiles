{ pkgs, ... }:
let
  wezterm-types = pkgs.fetchFromGitHub {
    owner = "DrKJeff16";
    repo = "wezterm-types";
    rev = "d8b1671db6de96e3c4e44ce5cfd1c9c31d3828bf";
    hash = "sha256-FdoMQk+t0Zi/TPAhxHFssQmWlzYyL/QG/KUfPz6QT1U=";
  };
in
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

          -- telescope は lazy ロードのため、require 直叩きではなく
          -- :Telescope コマンド経由で起動して lz.n の cmd トリガーを発火させる。
          lsp_map("gd", function()
            vim.cmd("Telescope lsp_definitions")
          end, "LSP definitions (Telescope)")
          lsp_map("gD", vim.lsp.buf.declaration, "LSP declaration")
          lsp_map("gri", function()
            vim.cmd("Telescope lsp_implementations")
          end, "LSP implementations (Telescope)")
          lsp_map("grr", function()
            vim.cmd("Telescope lsp_references")
          end, "LSP references (Telescope)")
          lsp_map("grt", function()
            vim.cmd("Telescope lsp_type_definitions")
          end, "LSP type definitions (Telescope)")
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
        settings = {
          workspace.library = [ "${wezterm-types}" ];
          diagnostics.globals = [ "vim" ];
        };
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
