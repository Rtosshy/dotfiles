_: {
  programs.emacs = {
    enable = true;
    extraConfig = builtins.readFile ./init.el;
    extraPackages =
      epkgs: with epkgs; [
        which-key
        leaf
      ];
  };
}
