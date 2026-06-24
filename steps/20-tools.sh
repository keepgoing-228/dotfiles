#!/usr/bin/env bash
# steps/20-tools.sh — mise (node/python/bun/neovim/lazygit) + tmux plugin manager.
set -euo pipefail
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$STEP_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

# --- 1. install mise ---
if has mise || [ -x "$HOME/.local/bin/mise" ]; then
    ok "mise already installed"
else
    log "Installing mise…"
    curl -fsSL https://mise.run | sh
fi
MISE_BIN="$(command -v mise || echo "$HOME/.local/bin/mise")"

# --- 2. link the repo's mise.toml as the global mise config ---
mise_cfg_dir="$HOME/.config/mise"
src_toml="$REPO_DIR/mise.toml"
dst_toml="$mise_cfg_dir/config.toml"
mkdir -p "$mise_cfg_dir"

if [ -L "$dst_toml" ] && [ "$(readlink "$dst_toml")" = "$src_toml" ]; then
    ok "mise config already linked"
else
    if [ -e "$dst_toml" ] && [ ! -L "$dst_toml" ]; then
        backup="$dst_toml.backup.$(date +%Y%m%d%H%M%S)"
        warn "backing up existing $dst_toml -> $backup"
        mv "$dst_toml" "$backup"
    fi
    ln -sfn "$src_toml" "$dst_toml"
    ok "linked mise config -> $src_toml"
fi

# --- 3. install everything declared in mise.toml ---
log "Installing tools via mise…"
"$MISE_BIN" install
"$MISE_BIN" reshim || true

# --- 4. tmux plugin manager (tpm) ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    ok "tpm already installed"
else
    log "Installing tpm…"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
