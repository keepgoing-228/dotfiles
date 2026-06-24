#!/usr/bin/env bash
# steps/00-system.sh — install base system packages + a Nerd Font for p10k.
set -euo pipefail
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$STEP_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

# --- 1. system packages from config/packages.txt ---
pkgs=()
while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"                              # strip trailing comment
    line="${line#"${line%%[![:space:]]*}"}"         # ltrim
    line="${line%"${line##*[![:space:]]}"}"         # rtrim
    if [ -n "$line" ]; then pkgs+=("$line"); fi
done < "$REPO_DIR/config/packages.txt"

if [ "${#pkgs[@]}" -gt 0 ]; then
    log "Installing system packages: ${pkgs[*]}"
    ensure_pkg "${pkgs[@]}"
fi

# --- 2. compiler toolchain (name differs per distro) ---
case "$PKG" in
    apt)    ensure_pkg build-essential ;;
    pacman) ensure_pkg base-devel ;;
    dnf)    _sudo dnf groupinstall -y "Development Tools" || ensure_pkg gcc make ;;
    brew)   : ;;  # provided by Xcode Command Line Tools on macOS
esac

# --- 3. Nerd Font (MesloLGS NF — p10k's recommended font) ---
install_nerd_font() {
    if [ "$OS" = macos ]; then
        if has brew; then
            brew install --cask font-meslo-lg-nerd-font || warn "Nerd Font cask install failed"
        else
            warn "Homebrew not found; skipping Nerd Font"
        fi
        return 0
    fi

    local font_dir="$HOME/.local/share/fonts"
    if ls "$font_dir"/MesloLGS*NF*.ttf >/dev/null 2>&1; then
        ok "Nerd Font already installed"
        return 0
    fi

    log "Installing MesloLGS NF…"
    mkdir -p "$font_dir"
    local base="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local f
    for f in "MesloLGS NF Regular.ttf" "MesloLGS NF Bold.ttf" \
             "MesloLGS NF Italic.ttf" "MesloLGS NF Bold Italic.ttf"; do
        curl -fsSL "$base/${f// /%20}" -o "$font_dir/$f" || warn "failed to download: $f"
    done
    if has fc-cache; then fc-cache -f "$font_dir" >/dev/null 2>&1 || true; fi
    ok "Nerd Font installed to $font_dir"
}
install_nerd_font
