{
  programs.nixvim = {
    autoCmd = [
      {
        event = "FileType";
        callback.__raw = ''
          function() pcall(vim.treesitter.start) end
        '';
      }
    ];

    plugins.treesitter = {
      enable = true;
      settings.ensure_installed = [
        "lua"
        "go"
        "rust"
        "yaml"
        "bash"
        "fish"
        "c"
        "cpp"
        "nix"
      ];
    };
  };
}
