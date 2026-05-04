_: {
  programs.fish.shellAbbrs = {
    drs = {
      expansion = "darwin-rebuild switch --flake ~/ghq/github.com/Rtosshy/dotfiles/nix-darwin";
      position = "anywhere";
    };
    nfu = {
      expansion = "nix flake update --flake ~/ghq/github.com/Rtosshy/dotfiles/nix-darwin";
      position = "anywhere";
    };
  };
}
