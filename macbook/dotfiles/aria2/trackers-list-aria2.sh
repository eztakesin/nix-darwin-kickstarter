#!/usr/bin/env bash
# trackers-list-aria2.sh
# Downloads the latest public BT tracker list and appends it to aria2.conf
#
# Usage: bash trackers-list-aria2.sh
# Cron:  0 6 * * 0  bash ~/.aria2/trackers-list-aria2.sh

set -euo pipefail

ARIA2_CONF="${HOME}/.aria2/aria2.conf"
TRACKER_URL="https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"

# Download tracker list, remove empty lines, join with comma
trackers=$(curl -fsSL "$TRACKER_URL" | grep -v '^$' | paste -sd ',' -)

if [[ -z "$trackers" ]]; then
    echo "ERROR: Failed to fetch tracker list" >&2
    exit 1
fi

# Remove old bt-tracker line and append new one
if grep -q '^bt-tracker=' "$ARIA2_CONF"; then
    sed -i.bak '/^bt-tracker=/d' "$ARIA2_CONF"
fi

echo "bt-tracker=${trackers}" >> "$ARIA2_CONF"
echo "Updated bt-tracker list ($(echo "$trackers" | tr ',' '\n' | wc -l | tr -d ' ') trackers)"
