#!/usr/bin/env bash
# trackers-list-aria2.sh
# Fetches the latest public BT tracker list and pushes it into the RUNNING
# aria2 daemon via RPC (aria2.changeGlobalOption).
#
# The old version appended bt-tracker= to aria2.conf; that no longer works —
# the config is a read-only nix-store symlink managed by home-manager
# (home/aria2.nix). RPC updates need no config write and take effect
# immediately. Downside: the list lives only in the running process, so run
# this again after restarting aria2 (or just rely on DHT/PEX until cron
# fires).
#
# Usage: bash trackers-list-aria2.sh
# Cron:  0 6 * * 0  bash ~/.aria2/trackers-list-aria2.sh

set -euo pipefail

ARIA2_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/aria2/aria2.conf"
TRACKER_URL="https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"
RPC_URL="http://127.0.0.1:6800/jsonrpc"

# Download tracker list, remove empty lines, join with comma
trackers=$(curl -fsSL "$TRACKER_URL" | grep -v '^$' | paste -sd ',' -)

if [[ -z "$trackers" ]]; then
    echo "ERROR: Failed to fetch tracker list" >&2
    exit 1
fi

secret=$(sed -n 's/^rpc-secret=//p' "$ARIA2_CONF")

result=$(curl -fsS "$RPC_URL" -H 'Content-Type: application/json' -d @- <<EOF
{"jsonrpc":"2.0","id":"trackers","method":"aria2.changeGlobalOption",
 "params":["token:${secret}", {"bt-tracker":"${trackers}"}]}
EOF
)

if [[ "$result" == *'"OK"'* ]]; then
    echo "Pushed bt-tracker list to running aria2 ($(echo "$trackers" | tr ',' '\n' | wc -l | tr -d ' ') trackers)"
else
    echo "ERROR: RPC update failed (is aria2 running with RPC on :6800?): $result" >&2
    exit 1
fi
