#!/usr/bin/env bash
#
# cleanup-ls-registrations.sh
#
# Cleans up stale Launch Services registrations that shadow the real app
# copies and hide them from Spotlight / the Apps view:
#   1. .app bundles registered at /nix/store paths (leftovers from the
#      pre-copyApps era when "Home Manager Apps" were symlinks, or from
#      launching GUI apps via store-pointing CLI wrappers like `zoom`)
#   2. Registrations pointing at paths that no longer exist (e.g. apps
#      previously installed via Homebrew cask and since removed)
# Then re-registers the correct app directories and refreshes the Dock.
#
# Safe to re-run. Note: pinentry-mac re-registers its store path whenever
# gpg-agent spawns it — that recurrence is harmless, ignore it.
#
# Usage: bash scripts/cleanup-ls-registrations.sh [--dry-run]
#
# -e is deliberately omitted: lsregister -u exits non-zero for entries
# that were already dropped (e.g. nested helper bundles), which is fine.
set -uo pipefail

LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
DRY_RUN=${1:-}

ok()   { printf '\033[32m[OK]\033[0m %s\n' "$1"; }
skip() { printf '\033[33m[SKIP]\033[0m %s\n' "$1"; }
info() { printf '\033[34m[INFO]\033[0m %s\n' "$1"; }

unregister() {
    if [[ "$DRY_RUN" == "--dry-run" ]]; then
        skip "would unregister: $1"
    else
        "$LSREG" -u "$1" > /dev/null 2>&1 && ok "unregistered: $1"
    fi
}

DUMP=$(mktemp /tmp/lsregister-dump-XXXX)
trap 'rm -f "$DUMP"' EXIT
"$LSREG" -dump > "$DUMP" 2> /dev/null

########################################
# 1. .app bundles registered at /nix/store paths
########################################
# dump path lines look like: "path:    /nix/store/xxx/Foo.app (0x1234)"
info "Scanning for /nix/store app registrations..."
mapfile -t nix_paths < <(sed -n 's|^ *path: *\(/nix/store/.*\.app\) (0x[0-9a-f]*)$|\1|p' "$DUMP" | sort -u)
if [[ ${#nix_paths[@]} -eq 0 ]]; then
    skip "no /nix/store registrations found"
else
    for p in "${nix_paths[@]}"; do
        unregister "$p"
    done
fi

########################################
# 2. Registrations pointing at deleted paths
########################################
info "Scanning for registrations of no-longer-existing apps..."
stale_found=0
mapfile -t all_paths < <(sed -n 's|^ *path: *\(/.*\.app\) (0x[0-9a-f]*)$|\1|p' "$DUMP" | sort -u)
for p in "${all_paths[@]}"; do
    case "$p" in
        /nix/store/*) continue ;;  # handled above
        /Applications/*|"$HOME"/*)
            if [[ ! -e "$p" ]]; then
                unregister "$p"
                stale_found=1
            fi
            ;;
    esac
done
[[ $stale_found -eq 0 ]] && skip "no stale registrations found"

[[ "$DRY_RUN" == "--dry-run" ]] && { info "dry run — nothing changed"; exit 0; }

########################################
# 3. Re-register the correct app directories
########################################
"$LSREG" -f -R "$HOME/Applications/Home Manager Apps" && ok "re-registered ~/Applications/Home Manager Apps"
if [[ -d "/Applications/Nix Apps" ]]; then
    "$LSREG" -f -R "/Applications/Nix Apps" && ok "re-registered /Applications/Nix Apps"
fi

########################################
# 4. Verify: remaining /nix/store registrations (0 expected)
########################################
remaining=$("$LSREG" -dump 2> /dev/null | sed -n 's|^ *path: *\(/nix/store/.*\.app\) (0x[0-9a-f]*)$|\1|p' | sort -u)
if [[ -z "$remaining" ]]; then
    ok "no /nix/store app registrations remain"
else
    info "still registered (launched from the store since cleanup started?):"
    printf '%s\n' "$remaining"
fi

########################################
# 5. Refresh Dock / Apps view
########################################
killall Dock && ok "Dock restarted — check the Apps view now"
