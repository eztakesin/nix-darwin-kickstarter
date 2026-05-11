#!/usr/bin/env bash
#
# setup-catppuccin-themes.sh
#
# Downloads and installs Catppuccin Latte themes for various apps.
# Safe to re-run; skips already-installed themes.
#
# Usage: bash scripts/setup-catppuccin-themes.sh
#
set -euo pipefail

FLAVOR="latte"
FLAVOR_CAP="Latte"
TMPDIR_BASE=$(mktemp -d /tmp/catppuccin-setup-XXXX)
trap 'rm -rf "$TMPDIR_BASE"' EXIT

ok()   { printf '\033[32m[OK]\033[0m %s\n' "$1"; }
skip() { printf '\033[33m[SKIP]\033[0m %s\n' "$1"; }
info() { printf '\033[34m[INFO]\033[0m %s\n' "$1"; }

########################################
# 1. bat — Catppuccin tmTheme
########################################
BAT_THEMES_DIR="$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")/themes"
BAT_THEME_FILE="$BAT_THEMES_DIR/Catppuccin ${FLAVOR_CAP}.tmTheme"

if [[ -f "$BAT_THEME_FILE" ]]; then
    skip "bat: Catppuccin ${FLAVOR_CAP} already installed"
else
    info "bat: Installing Catppuccin ${FLAVOR_CAP} theme..."
    mkdir -p "$BAT_THEMES_DIR"
    curl -fsSL -o "$BAT_THEME_FILE" \
        "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20${FLAVOR_CAP}.tmTheme"
    bat cache --build > /dev/null 2>&1
    ok "bat: Catppuccin ${FLAVOR_CAP} installed"
fi

########################################
# 2. btop — Catppuccin theme file
########################################
BTOP_THEMES_DIR="$HOME/.config/btop/themes"
BTOP_THEME_FILE="$BTOP_THEMES_DIR/catppuccin_${FLAVOR}.theme"

if [[ -f "$BTOP_THEME_FILE" ]]; then
    skip "btop: catppuccin_${FLAVOR} already installed"
else
    info "btop: Installing catppuccin_${FLAVOR} theme..."
    mkdir -p "$BTOP_THEMES_DIR"
    cd "$TMPDIR_BASE"
    git clone --depth 1 --quiet https://github.com/catppuccin/btop.git
    cp "btop/themes/catppuccin_${FLAVOR}.theme" "$BTOP_THEME_FILE"
    ok "btop: catppuccin_${FLAVOR} installed -> set in btop Options"
fi

########################################
# 3. OBS Studio — macOS theme dir
########################################
OBS_THEMES_DIR="$HOME/Library/Application Support/obs-studio/themes"
OBS_MARKER="$OBS_THEMES_DIR/.catppuccin-installed"

if [[ -f "$OBS_MARKER" ]]; then
    skip "OBS: Catppuccin themes already installed"
else
    info "OBS: Installing Catppuccin themes..."
    mkdir -p "$OBS_THEMES_DIR"
    cd "$TMPDIR_BASE"
    git clone --depth 1 --quiet https://github.com/catppuccin/obs.git
    cp -R obs/themes/* "$OBS_THEMES_DIR/"
    touch "$OBS_MARKER"
    ok "OBS: Catppuccin installed -> select in OBS Settings > Appearance"
fi

########################################
# 4. Thunderbird — download xpi files
########################################
TB_THEMES_DIR="$HOME/.config/catppuccin-themes/thunderbird"

if [[ -d "$TB_THEMES_DIR" ]]; then
    skip "Thunderbird: xpi themes already downloaded"
else
    info "Thunderbird: Downloading theme xpi files..."
    mkdir -p "$TB_THEMES_DIR"
    cd "$TMPDIR_BASE"
    git clone --depth 1 --quiet https://github.com/catppuccin/thunderbird.git
    cp -R thunderbird/themes/* "$TB_THEMES_DIR/"
    ok "Thunderbird: xpi files downloaded to $TB_THEMES_DIR"
    info "  -> Open Thunderbird > Settings > Add-ons > Install Add-on From File"
    info "  -> Select: $TB_THEMES_DIR/${FLAVOR}/${FLAVOR}-blue.xpi (or preferred accent)"
fi

########################################
# 5. qBittorrent — download .qbtheme
########################################
QB_THEMES_DIR="$HOME/.config/catppuccin-themes/qbittorrent"
QB_THEME_FILE="$QB_THEMES_DIR/catppuccin-${FLAVOR}.qbtheme"

if [[ -f "$QB_THEME_FILE" ]]; then
    skip "qBittorrent: catppuccin-${FLAVOR}.qbtheme already downloaded"
else
    info "qBittorrent: Downloading catppuccin-${FLAVOR}.qbtheme..."
    mkdir -p "$QB_THEMES_DIR"
    # Download from latest GitHub release
    curl -fsSL -o "$QB_THEME_FILE" \
        "https://github.com/catppuccin/qbittorrent/releases/latest/download/catppuccin-${FLAVOR}.qbtheme" \
        || {
            # Fallback: clone and build
            info "  Direct download failed, cloning repo..."
            cd "$TMPDIR_BASE"
            git clone --depth 1 --quiet https://github.com/catppuccin/qbittorrent.git
            if [[ -f "qbittorrent/themes/catppuccin-${FLAVOR}.qbtheme" ]]; then
                cp "qbittorrent/themes/catppuccin-${FLAVOR}.qbtheme" "$QB_THEME_FILE"
            else
                info "  Theme file not found in repo, check releases manually"
            fi
        }
    if [[ -f "$QB_THEME_FILE" ]]; then
        ok "qBittorrent: theme downloaded to $QB_THEME_FILE"
        info "  -> Open qBittorrent > Tools > Preferences > Behaviour"
        info "  -> Tick 'Use custom UI theme' and select: $QB_THEME_FILE"
    fi
fi

########################################
# 6. mpv — Catppuccin config
########################################
MPV_CONF_DIR="$HOME/.config/mpv"
MPV_THEME_MARKER="$MPV_CONF_DIR/.catppuccin-installed"

if [[ -f "$MPV_THEME_MARKER" ]]; then
    skip "mpv: Catppuccin theme already installed"
else
    info "mpv: Installing Catppuccin ${FLAVOR_CAP} theme..."
    mkdir -p "$MPV_CONF_DIR"
    cd "$TMPDIR_BASE"
    git clone --depth 1 --quiet https://github.com/catppuccin/mpv.git
    if [[ -f "mpv/themes/${FLAVOR}/green.conf" ]]; then
        cp "mpv/themes/${FLAVOR}/green.conf" "$MPV_CONF_DIR/script-opts/osc-${FLAVOR}.conf" 2>/dev/null \
            || cp "mpv/themes/${FLAVOR}/green.conf" "$MPV_CONF_DIR/catppuccin-${FLAVOR}.conf"
        touch "$MPV_THEME_MARKER"
        ok "mpv: Catppuccin ${FLAVOR_CAP} theme installed"
    else
        info "  mpv theme structure changed, check https://github.com/catppuccin/mpv"
    fi
fi

########################################
echo ""
echo "========================================"
echo "  Catppuccin ${FLAVOR_CAP} theme setup complete!"
echo "========================================"
echo ""
echo "Manual steps needed:"
echo "  - btop: Launch btop > Esc > Options > select catppuccin_${FLAVOR}"
echo "  - OBS: Settings > Appearance > Theme: Catppuccin, Style: ${FLAVOR_CAP}"
echo "  - Thunderbird: Settings > Add-ons > Install from file > select xpi"
echo "  - qBittorrent: Preferences > Behaviour > Custom UI theme > select .qbtheme"
echo ""
