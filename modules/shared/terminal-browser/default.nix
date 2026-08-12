{ pkgs, ... }:
let
  terminalBrowserPkg = pkgs.callPackage ./package.nix { };
in
{
  home.packages = [ terminalBrowserPkg ];

  home.file.".claude/skills/terminal-browser/SKILL.md".source =
    "${terminalBrowserPkg}/skill/SKILL.md";
}
