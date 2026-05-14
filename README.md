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
generic Ubuntu / Debian / Fedora servers, WSL2, etc. Targets the current Linux
system, such as `x86_64-linux` or `aarch64-linux`, and CLI modules only (no GUI).

The output reads `username` and `homeDirectory` from `$USER` / `$HOME` at
activation time, so the same flake works in any container regardless of the
default user (`vscode`, `node`, `codespace`, `ubuntu`, ...). This requires
`--impure` on every Nix command that touches the output.

```sh
# 1. Install Nix in single-user mode (no systemd / no daemon)
curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install.sh
sh /tmp/nix-install.sh --no-daemon

# 2. Load the Nix profile into the current shell
. ~/.nix-profile/etc/profile.d/nix.sh

# 3. Persist the profile load for future shells (non-login terminals)
echo '[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"' \
  >> ~/.bashrc

# 4. Enable flakes and the nix-command CLI
mkdir -p ~/.config/nix \
  && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 5. First-time activation (no clone required; --refresh forces a fresh fetch)
nix run home-manager/master -- switch \
  --flake github:Rtosshy/dotfiles#standalone --impure --refresh

# 6. Subsequent rebuilds (home-manager CLI is on PATH after step 5)
home-manager switch --flake github:Rtosshy/dotfiles#standalone --impure --refresh
```

For long-lived hosts where the config will be edited locally (EC2, WSL2,
etc.), clone to the standard ghq location and switch from there:

```sh
git clone https://github.com/Rtosshy/dotfiles ~/ghq/github.com/Rtosshy/dotfiles
cd ~/ghq/github.com/Rtosshy/dotfiles
home-manager switch --flake .#standalone --impure
```

#### Why upstream installer + `--no-daemon`

The Determinate Systems installer (otherwise nicer) sets up a multi-user Nix
backed by a systemd unit. Codespaces and most generic Linux containers do not
run systemd as PID 1 (`docker-init` / `tini`), so the daemon never starts and
every `nix` invocation fails with `cannot connect to socket at
'/nix/var/nix/daemon-socket/socket'`. Single-user mode (`--no-daemon`) sidesteps
this entirely — `/nix` is owned by `$USER` and operations run without a daemon.

The `~/.bashrc` source line in step 3 exists because Codespaces' VS Code
terminals are non-login shells; the installer only patches `~/.bash_profile`,
so `nix` would silently disappear from PATH in new terminals without that line.

Step 4 is required because the upstream installer ships a conservative default
that disables `nix-command` and flakes. Every command in this README assumes
both are enabled.

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
