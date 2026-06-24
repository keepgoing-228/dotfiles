# Tim's dotfiles

Modular, idempotent bootstrap for a fresh machine. Linux first, macOS best-effort.

## Install

On a brand-new machine (user already created), get `git` then clone and run:

```sh
# Debian/Ubuntu — install git first (other distros: dnf/pacman)
sudo apt-get update && sudo apt-get install -y git

git clone https://github.com/keepgoing-228/dotfiles.git ~/Github/dotfiles
cd ~/Github/dotfiles
./install.sh
```

`install.sh` is safe to re-run. Open a new shell afterwards to load the environment.

## What it does

| Step | What |
|------|------|
| `00-system` | System packages (`config/packages.txt`) + compiler toolchain + a Nerd Font |
| `10-shell`  | oh-my-zsh, powerlevel10k, zsh plugins, sets zsh as the default shell |
| `20-tools`  | mise + everything in `mise.toml` (node, python, bun, neovim, lazygit) + tpm + clones the neovim config |
| `30-stow`   | Backs up conflicting files, then `stow`s `zsh/p10k/tmux/git` into `$HOME` |

`20-tools` also clones the Neovim config (a standalone [kickstart.nvim](https://github.com/keepgoing-228/kickstart.nvim) fork) into `~/.config/nvim` if absent. It stays its own git repo; lazy.nvim installs the plugins (latest, since `lazy-lock.json` isn't pinned) on first launch.

## Usage

```sh
./install.sh            # run every step in order
./install.sh --list     # list steps
./install.sh 20         # re-run a single step (by number or name, e.g. 20-tools)
```

## Layout

```
install.sh            # runner: detects OS, runs steps, supports single-step re-runs
lib/common.sh         # logging, OS/package-manager detection, ensure_pkg()
steps/                # 00-system, 10-shell, 20-tools, 30-stow
config/packages.txt   # declarative system package list
mise.toml             # declarative dev-tool versions
zsh/ p10k/ tmux/ git/ # stow packages
```

Dev tools (node/python/bun/neovim/lazygit) are managed declaratively by **mise** —
edit `mise.toml` and run `mise install`.
