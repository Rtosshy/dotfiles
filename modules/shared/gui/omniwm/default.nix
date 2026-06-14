{ lib, ... }:

{
  # OmniWM rewrites settings.toml after loading it, so deploy it as a real
  # writable file instead of a Home Manager symlink to the Nix store.
  home.activation.materializeOmniWMSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -Dm644 ${./settings.toml} $HOME/.config/omniwm/settings.toml
  '';
}
