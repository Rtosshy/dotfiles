{ ... }: {
  home.file."Library/Application Support/lazygit/config.yml" = {
    force = true;
    text = ''
      gui:
        showIcons: true
        nerdFontsVersion: "3"
        border: single

      git:
        disableForcePushing: true

      confirmOnQuit: true

      os:
        editPreset: nvim
    '';
  };
}
