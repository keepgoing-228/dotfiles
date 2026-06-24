#!/usr/bin/env bash
# lib/common.sh — shared helpers + OS / package-manager detection.
# Sourced by install.sh and every steps/*.sh. Safe to source repeatedly.

# ----- pretty logging -----
if [ -t 1 ]; then
    _C_RESET=$'\033[0m'; _C_BLUE=$'\033[34m'; _C_GREEN=$'\033[32m'
    _C_YELLOW=$'\033[33m'; _C_RED=$'\033[31m'
else
    _C_RESET=; _C_BLUE=; _C_GREEN=; _C_YELLOW=; _C_RED=
fi

log()  { printf '%s[+]%s %s\n' "$_C_BLUE"   "$_C_RESET" "$*"; }
ok()   { printf '%s[\xe2\x9c\x93]%s %s\n' "$_C_GREEN" "$_C_RESET" "$*"; }
warn() { printf '%s[!]%s %s\n' "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
err()  { printf '%s[\xe2\x9c\x97]%s %s\n' "$_C_RED"  "$_C_RESET" "$*" >&2; }

# has <cmd> — is an executable on PATH?
has() { command -v "$1" >/dev/null 2>&1; }

# ----- OS / package-manager detection -----
# Sets and exports OS (linux|macos|unknown) and PKG (apt|dnf|pacman|brew|unknown).
detect_platform() {
    case "$(uname -s)" in
        Darwin) OS=macos ;;
        Linux)  OS=linux ;;
        *)      OS=unknown ;;
    esac

    if [ "$OS" = macos ]; then
        PKG=brew
    elif has apt-get; then
        PKG=apt
    elif has dnf; then
        PKG=dnf
    elif has pacman; then
        PKG=pacman
    elif has brew; then
        PKG=brew
    else
        PKG=unknown
    fi
    export OS PKG
}

# _sudo <cmd...> — run as-is when root, otherwise prefix with sudo.
_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Refresh the package index at most once per process.
_PKG_UPDATED=0
pkg_update_once() {
    if [ "$_PKG_UPDATED" -eq 1 ]; then return 0; fi
    case "$PKG" in
        apt)    _sudo apt-get update ;;
        pacman) _sudo pacman -Sy --noconfirm ;;
        brew)   has brew && brew update ;;
        dnf)    : ;;  # dnf refreshes metadata on demand
    esac
    _PKG_UPDATED=1
}

# ensure_pkg <pkg...> — install system packages via the detected manager.
ensure_pkg() {
    if [ "$#" -eq 0 ]; then return 0; fi
    case "$PKG" in
        apt)    pkg_update_once; _sudo apt-get install -y "$@" ;;
        dnf)    _sudo dnf install -y "$@" ;;
        pacman) _sudo pacman -S --needed --noconfirm "$@" ;;
        brew)   brew install "$@" ;;
        *)      err "No supported package manager found; install manually: $*"; return 1 ;;
    esac
}
