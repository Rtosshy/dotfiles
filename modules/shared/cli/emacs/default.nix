_: {
  programs.emacs = {
    enable = true;
    extraPackages =
      epkgs: with epkgs; [
        which-key
      ];
  };
}
