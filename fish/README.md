# Fish shell configuration

## File structure

```
fish/
├── conf.d/
│   ├── 00_paths.fish    # Static PATH entries (homebrew, go, pixi)
│   ├── 01_mise.fish     # mise activation + immediate hook-env
│   └── 99_abbrs.fish    # Abbreviations (depends on tools being in PATH)
├── config.fish          # Shell options, key bindings, prompt setup
├── functions/           # Autoloaded functions
└── completions/         # Custom completions
```

## Decision record: mise activation strategy

### Context

Tools managed by mise (eza, nvim, bat, ripgrep, etc.) were intermittently unavailable after opening a new terminal tab or running `exec fish`. Abbreviations like `ls → eza --icons` also failed to register.

### Problem

Two issues were compounding:

**1. `set -gx PATH` was overwriting mise's PATH entries**

`config.fish` originally contained `set -gx PATH /usr/bin /bin /opt/homebrew/bin ...`, which completely replaced PATH on every shell startup. Since vendor_conf.d's mise-activate.fish runs and adds tool paths before config.fish, this line wiped out everything mise had set up.

Fix: replaced `set -gx PATH` with `fish_add_path -g`, which appends without destroying existing entries.

**2. vendor_conf.d executes after user conf.d**

Fish loads conf.d scripts in basename-sorted order across all directories, but user conf.d files run before vendor_conf.d files ([fish-shell#8553](https://github.com/fish-shell/fish-shell/issues/8553)). This means:

```
1. conf.d/00_paths.fish              ← PATH has no mise tools
2. conf.d/99_abbrs.fish              ← command -q eza → false, abbreviation not registered
3. vendor_conf.d/mise-activate.fish  ← mise tools finally added to PATH
4. config.fish
```

By the time mise's auto-activation runs, `99_abbrs.fish` has already evaluated `command -q` and skipped the abbreviation registration. Even after `cd` triggers hook-env and restores tools to PATH, abbreviations are not re-evaluated.

### Solution

Disabled vendor_conf.d auto-activation and manage mise explicitly in `conf.d/01_mise.fish`:

```fish
# conf.d/01_mise.fish
mise activate fish | source    # Register hooks for cd / prompt
mise hook-env -s fish | source # Immediately populate PATH
```

This ensures tools are in PATH before `99_abbrs.fish` runs.

Required universal variable (run once):

```fish
set -Ux MISE_FISH_AUTO_ACTIVATE 0
```

### Key concepts learned

- **`set -gx PATH` vs `fish_add_path -g`**: `set -gx` overwrites; `fish_add_path` appends without duplicates. Never use `set -gx PATH` in config files.
- **`mise activate` vs `mise hook-env`**: `activate` registers shell hooks that call `hook-env` on prompt display and `cd`. `hook-env` is the command that actually modifies PATH. In conf.d, `activate` alone isn't enough — `hook-env` must be called explicitly to populate PATH before the first prompt.
- **Universal variables (`set -Ux`)**: Persisted in `fish_variables`, available before any script runs. Useful for flags like `MISE_FISH_AUTO_ACTIVATE` that must be set before vendor_conf.d executes. Avoid for PATH management — entries become invisible and hard to track.
- **`exec fish` inherits environment**: `exec` replaces the process but inherits the parent's environment variables. Changes to universal variables or `fish_variables` require a completely new terminal session (not just `exec fish`) to take full effect.
