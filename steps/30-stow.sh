#!/usr/bin/env bash
# steps/30-stow.sh — back up conflicting real files, then stow the dotfiles.
set -euo pipefail
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$STEP_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

DOT_FOLDERS="zsh,p10k,tmux,git"

for folder in ${DOT_FOLDERS//,/ }; do
    log "stow :: $folder"

    # Back up existing real files that would conflict (skip symlinks we own).
    while IFS= read -r src; do
        rel="${src#"$REPO_DIR/$folder/"}"
        target="$HOME/$rel"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
            warn "backing up $target -> $backup"
            mv "$target" "$backup"
        fi
    done < <(find "$REPO_DIR/$folder" -type f ! -name 'README.md' ! -name 'LICENSE')

    # Restow: removes stale links then re-creates them — idempotent.
    stow --ignore=README.md --ignore=LICENSE -d "$REPO_DIR" -t "$HOME" -R "$folder"
done

ok "dotfiles linked"
