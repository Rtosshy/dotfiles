{
  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "s";
      action = "<cmd>lua require('flash').jump()<CR>";
      options = {
        silent = true;
        desc = "Flash jump";
      };
    }
  ];

  plugins.flash = {
    enable = true;
    settings.label = {
      before = true;
      after = false;
    };
    settings.modes.search.enabled = true;
  };
}
