{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ghc
    cabal-install
    ormolu
  ];
}
