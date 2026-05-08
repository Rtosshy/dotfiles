### fish

```fish
exec fish
```

### Nix modules

- `flake.nix`: root entrypoint for host configurations.
- `hosts/`: machine-specific composition.
- `modules/shared/`: Home Manager modules shared across platforms.
- `modules/shared/cli/`: CLI modules imported by default.
- `modules/shared/gui/`: GUI modules imported by GUI-capable hosts.
- `modules/darwin/`: Darwin-only modules split by nix-darwin and Home Manager layer.
- `modules/nixos/`: reserved for future NixOS modules.
