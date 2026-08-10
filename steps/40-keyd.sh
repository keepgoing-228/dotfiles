#!/usr/bin/env bash
# steps/40-keyd.sh — keyd key-remapping daemon + the repo's /etc/keyd config.
set -euo pipefail
STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$STEP_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

# Only bumped when falling back to a source build; packaged installs follow the
# distro's version.
KEYD_VERSION=v2.6.0
KEYD_REPO=https://github.com/rvaiya/keyd

CONF_SRC="$REPO_DIR/keyd/default.conf"
CONF_DST=/etc/keyd/default.conf

# --- 0. keyd is Linux-only (it is an evdev/uinput daemon) ---
if [ "$OS" != linux ]; then
    ok "keyd is Linux-only; skipping"
    exit 0
fi

# --- 1. install keyd: packaged where available, source build otherwise ---
# Ubuntu ships keyd from 25.10 (questing) on; 24.04 LTS has no package, hence
# the fallback. Packaged builds land in /usr/bin, source builds in /usr/local/bin
# — everything below only touches /etc/keyd and systemd, so either is fine.
if has keyd; then
    ok "keyd already installed ($(keyd --version 2>/dev/null | head -1))"
elif pkg_available keyd; then
    log "Installing keyd via $PKG…"
    ensure_pkg keyd
else
    log "keyd is not packaged for this release; building $KEYD_VERSION from source…"
    build_dir="$(mktemp -d)"
    trap 'rm -rf "$build_dir"' EXIT
    git clone --depth=1 --branch "$KEYD_VERSION" "$KEYD_REPO" "$build_dir"
    make -C "$build_dir"
    _sudo make -C "$build_dir" install
    ok "keyd $KEYD_VERSION built and installed"
fi

# --- 2. validate the config before it goes anywhere near /etc ---
keyd check "$CONF_SRC"

# --- 3. link the repo's config as /etc/keyd/default.conf ---
# Lets you edit keybindings without sudo; only `keyd reload` needs root.
_sudo mkdir -p "$(dirname "$CONF_DST")"

if [ -L "$CONF_DST" ] && [ "$(readlink "$CONF_DST")" = "$CONF_SRC" ]; then
    ok "keyd config already linked"
else
    if [ -e "$CONF_DST" ] && [ ! -L "$CONF_DST" ]; then
        # keyd loads *every* *.conf in /etc/keyd, so the backup suffix must not
        # end in .conf or it gets loaded as a second, conflicting config.
        backup="$CONF_DST.backup.$(date +%Y%m%d%H%M%S)"
        warn "backing up existing $CONF_DST -> $backup"
        _sudo mv "$CONF_DST" "$backup"
    fi
    _sudo ln -sfn "$CONF_SRC" "$CONF_DST"
    ok "linked keyd config -> $CONF_SRC"
fi

# --- 4. enable the daemon and pick up the config ---
if has systemctl; then
    # daemon-reload so a unit installed by the source build above is visible.
    _sudo systemctl daemon-reload
    _sudo systemctl enable --now keyd
    _sudo keyd reload || warn "keyd reload failed; check 'systemctl status keyd'"
    ok "keyd running"
else
    warn "no systemctl; start keyd manually"
fi
