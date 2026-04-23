{ ... }: {
  home.file."Library/Application Support/lazygit/config.yml" = {
    force = true;
    text = ''
      os:
        editPreset: nvim
    '';
  };
}
