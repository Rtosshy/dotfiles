{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "gq";
        action.__raw = ''
          function()
            require("conform").format({ async = true })
          end
        '';
        options.desc = "Format";
      }
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          go = [ "gofmt" ];
          cpp = [ "clang-format" ];
          c = [ "clang-format" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
  };
}
