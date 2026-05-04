_: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        nerdFontsVersion = "3";
        border = "single";
      };

      git.disableForcePushing = true;
      confirmOnQuit = true;
      os.editPreset = "nvim";
    };
  };
}
