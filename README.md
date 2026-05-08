# dotfiles

## Layout

- `flake.nix`: root entrypoint for host configurations.
- `hosts/`: machine-specific composition.
- `modules/shared/`: Home Manager modules shared across platforms.
- `modules/shared/cli/`: CLI modules imported by default.
- `modules/shared/gui/`: GUI modules imported by GUI-capable hosts.
- `modules/darwin/`: Darwin-only modules split by nix-darwin and Home Manager layer.
- `modules/nixos/`: reserved for future NixOS modules.
- `dev/`: dev shell with formatters and linters used by hooks.

## Install

### macOS (`darwinConfigurations."MacBook-V3"`)

Prerequisite: install Nix (Determinate Systems installer recommended) and
`nix-darwin`.

```sh
git clone https://github.com/Rtosshy/dotfiles ~/ghq/github.com/Rtosshy/dotfiles
cd ~/ghq/github.com/Rtosshy/dotfiles

# First-time activation
nix run nix-darwin -- switch --flake .#MacBook-V3

# Subsequent rebuilds
darwin-rebuild switch --flake .#MacBook-V3
```

After activation the `drs` / `nfu` fish abbreviations point at this repo.

### Non-NixOS Linux (`homeConfigurations."standalone"`)

For Codespaces spawned from OSS project devcontainers, remote dev boxes,
generic Ubuntu / Debian / Fedora servers, WSL2, etc. Targets `x86_64-linux`
and CLI modules only (no GUI).

The output reads `username` and `homeDirectory` from `$USER` / `$HOME` at
activation time, so the same flake works in any container regardless of the
default user (`vscode`, `node`, `codespace`, `ubuntu`, ...). This requires
`--impure` on every Nix command that touches the output.

```sh
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# 2. One-shot activation (no clone required)
nix run home-manager/master -- switch \
  --flake github:Rtosshy/dotfiles#standalone --impure

# Subsequent rebuilds
home-manager switch --flake github:Rtosshy/dotfiles#standalone --impure
```

#### Why `--impure`

The natural alternative — enumerating supported users as `tosshy@standalone`,
`vscode@standalone`, `codespace@standalone`, ... — fails the moment we land in
a container with an unanticipated default user, and forces a `flake.nix` edit
+ push + pull every time we meet a new one. Since the typical use case is
"drop into someone else's OSS Codespace and run a single command", reading
`$USER` / `$HOME` from the environment is a deliberate trade-off: we give up
flake purity in exchange for working in any container without
preconfiguration.

CI uses `nix flake check --impure`. Pure `nix flake check` (or any pure
evaluation that touches the activation package) fails with an assertion
message pointing at `--impure`.

> First activation builds ~430 derivations (mostly nixvim treesitter grammars)
> and takes a while. The Nix binary cache covers most of it; fully cold builds
> are uncommon.

## Dev shell

Formatters and linters used by the hooks live in `dev/flake.nix`. `direnv`
loads them automatically via `.envrc` (`use flake ./dev`).

```sh
direnv allow         # one-time per checkout
nix develop ./dev    # or enter manually
```

## fish

```fish
exec fish
```
