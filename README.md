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
- `modules/darwin/`: nix-darwin system modules and Darwin-only Home Manager additions.
- `modules/nixos/`: reserved for future NixOS modules.
