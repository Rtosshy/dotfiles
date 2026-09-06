# Template for a new Darwin host.
#
# This file is a skeleton, not a live host: nothing in flake.nix imports it, so
# it is never evaluated. Copy it instead of editing it in place.
#
#   cp systems/darwin/template.nix systems/darwin/macbook-v4.nix
#
# Then register the host in flake.nix:
#
#   darwinConfigurations."MacBook-V4" = nix-darwin.lib.darwinSystem {
#     modules = [ ./systems/darwin/macbook-v4.nix ];
#     specialArgs = { inherit inputs home-manager; };
#   };
#
#   nix run nix-darwin -- switch --flake .#MacBook-V4   # first activation
#   darwin-rebuild switch --flake .#MacBook-V4          # afterwards
#
# The flake output name, `networking.hostName` below, and the file name are
# independent; keeping them aligned is what makes `.#MacBook-V4` readable.
#
# Values a new machine may need that are NOT host-local today. They live in the
# shared modules because there has only ever been one Darwin host; a second
# host with a different user or CPU has to move them out into this file first:
#
#   modules/darwin/nix-darwin/system    system.primaryUser
#                                       users.knownUsers, users.users.<user>
#                                       users.users.<user>.uid  (`id -u`)
#                                       nixpkgs.hostPlatform    (aarch64/x86_64)
#   modules/darwin/nix-darwin/homebrew  nix-homebrew.user
#                                       homebrew.casks
#
# The `apps` in flake.nix (build, check, home-switch, darwin-switch) hardcode
# the MacBook-V3 output names. They keep targeting the old machine until
# updated, without failing.
#
# See README.md for the full new-machine checklist.

{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../modules/darwin/nix-darwin/system
    ../../modules/darwin/nix-darwin/homebrew
  ];

  networking = {
    # `scutil --set HostName`. Shown at the shell prompt and over SSH.
    hostName = "CHANGE-ME";
    # `scutil --set ComputerName`. System Settings > General > Sharing.
    # Spaces and Unicode are allowed here, unlike hostName.
    computerName = "CHANGE-ME";
  };
}
