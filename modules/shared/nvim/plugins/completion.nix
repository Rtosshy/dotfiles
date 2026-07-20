{
  plugins = {
    friendly-snippets.enable = true;

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        completion = {
          list.selection = {
            preselect = false;
            auto_insert = false;
          };
          documentation.auto_show = true;
        };

        keymap = {
          preset = "none";
          "<C-b>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-f>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-Space>" = [ "show" ];
          "<C-e>" = [
            "hide"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<Tab>" = [
            "select_and_accept"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
        };

        sources = {
          default = [
            "lsp"
            "snippets"
            "path"
            "buffer"
          ];
          min_keyword_length = 1;
        };
      };
    };
  };
}
