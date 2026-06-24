#!/usr/bin/env bash
# install.sh — bootstrap these dotfiles on a fresh machine.
#
#   ./install.sh            run every step in order (00 -> 10 -> 20 -> 30)
#   ./install.sh 20         run only the matching step (e.g. 20-tools)
#   ./install.sh 20-tools   same, by full name
#   ./install.sh --list     list available steps
#
# Each step is idempotent and safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
detect_platform

STEPS_DIR="$REPO_DIR/steps"

usage() {
    sed -n '2,9p' "$REPO_DIR/install.sh" | sed 's/^# \{0,1\}//'
}

list_steps() {
    for s in "$STEPS_DIR"/*.sh; do
        printf '  %s\n' "$(basename "$s" .sh)"
    done
}

# run_step <path> — execute one step in its own subshell, isolating failures.
run_step() {
    local file="$1" name
    name="$(basename "$file" .sh)"
    log "step ${name}…"
    if bash "$file"; then
        ok "step ${name} done"
    else
        local rc=$?
        err "step ${name} failed (exit $rc)"
        err "re-run just this step with:  ./install.sh ${name%%-*}"
        exit "$rc"
    fi
}

main() {
    case "${1:-}" in
        -h|--help) usage; exit 0 ;;
        -l|--list) list_steps; exit 0 ;;
    esac

    if [ "$#" -eq 0 ]; then
        log "Platform: OS=$OS PKG=$PKG"
        for s in "$STEPS_DIR"/*.sh; do
            run_step "$s"
        done
        ok "All steps complete."
        warn "Open a new shell (or run: exec zsh -l) to load the new environment."
        return 0
    fi

    # Run only the step(s) matching the argument by name or numeric prefix.
    local arg="$1" matched=0 name
    for s in "$STEPS_DIR"/*.sh; do
        name="$(basename "$s" .sh)"
        if [ "$name" = "$arg" ] || [ "${name%%-*}" = "$arg" ]; then
            run_step "$s"
            matched=1
        fi
    done
    if [ "$matched" -eq 0 ]; then
        err "No step matches '$arg'. Available steps:"
        list_steps
        exit 1
    fi
}

main "$@"
