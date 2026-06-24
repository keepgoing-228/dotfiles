#!/usr/bin/env bash
# steps/10-shell.sh — oh-my-zsh, powerlevel10k, zsh plugins, default shell.
set -euo pipefail
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$STEP_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

# --- 1. oh-my-zsh (keep our own .zshrc, don't launch a shell) ---
if [ ! -d "$ZSH_DIR" ]; then
    log "Installing oh-my-zsh…"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    ok "oh-my-zsh already installed"
fi

# --- 2. theme + plugins ---
clone_if_absent() {
    local dest="$1" url="$2"
    if [ -d "$dest" ]; then
        ok "$(basename "$dest") already present"
    else
        log "Cloning $(basename "$dest")…"
        git clone --depth=1 "$url" "$dest"
    fi
}

clone_if_absent "$ZSH_CUSTOM/themes/powerlevel10k"        https://github.com/romkatv/powerlevel10k.git
clone_if_absent "$ZSH_CUSTOM/plugins/zsh-autosuggestions" https://github.com/zsh-users/zsh-autosuggestions
clone_if_absent "$ZSH_CUSTOM/plugins/pwp"                 https://github.com/ttkalcevic/pwp.git

# --- 3. make zsh the default shell ---
zsh_path="$(command -v zsh || true)"
if [ -z "$zsh_path" ]; then
    warn "zsh not found on PATH; run step 00 first"
else
    case "${SHELL:-}" in
        *zsh)
            ok "Default shell is already zsh"
            ;;
        *)
            log "Setting default shell to zsh ($zsh_path)…"
            if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
                printf '%s\n' "$zsh_path" | _sudo tee -a /etc/shells >/dev/null || \
                    warn "could not register zsh in /etc/shells"
            fi
            # sudo chsh avoids a password prompt in automated runs.
            _sudo chsh -s "$zsh_path" "$USER" || warn "chsh failed; run 'chsh -s $zsh_path' manually"
            ;;
    esac
fi
