{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../../modules/darwin/nix-darwin/system
    ../../../modules/darwin/nix-darwin/homebrew
  ];
}
