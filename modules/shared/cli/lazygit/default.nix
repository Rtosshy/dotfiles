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

      customCommands = [
        {
          key = "H";
          context = "localBranches";
          description = "Open selected branch in a Herdr worktree";
          command = "herdr worktree open --branch '{{.SelectedLocalBranch.Name}}' --focus || herdr worktree create --branch '{{.SelectedLocalBranch.Name}}' --focus";
          loadingText = "Opening Herdr worktree";
        }
      ];
    };
  };
}
