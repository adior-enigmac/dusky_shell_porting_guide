#!/usr/bin/env bash
# ==============================================================================
# Dusky Universal Two-Way Wallpaper Synchronizer
# Works across Dusky native, Serpantinum, and iNiR (Iris, Material II, Waffle)
# ==============================================================================

set -euo pipefail

WP_PATH="${1:-}"

# If no path provided, detect current wallpaper from system state
if [[ -z "$WP_PATH" ]]; then
    # 1. Check running skwd-wall-still instance
    CURRENT_RUNNING="$(ps aux 2>/dev/null | grep "[s]kwd-wall-still" | grep -oP '/home/[^ "]+' | head -n 1 || true)"
    if [[ -n "$CURRENT_RUNNING" && -f "$CURRENT_RUNNING" ]]; then
        WP_PATH="$CURRENT_RUNNING"
    fi

    # 2. Check awww query if active
    if [[ -z "$WP_PATH" && $(command -v awww 2>/dev/null) ]]; then
        WP_PATH="$(awww query 2>/dev/null | grep -oP 'image: \K.*' | head -n 1 || true)"
    fi

    # 3. Check current_wallpaper cache
    if [[ -z "$WP_PATH" || ! -f "$WP_PATH" ]]; then
        if [[ -f "$HOME/.cache/current_wallpaper" ]]; then
            CACHED="$(head -n 1 "$HOME/.cache/current_wallpaper" 2>/dev/null | tr -d '[:space:]')"
            [[ -n "$CACHED" && -f "$CACHED" ]] && WP_PATH="$CACHED"
        fi
    fi

    # 4. Check skwd-wall-v2 config lastAppliedKey
    if [[ -z "$WP_PATH" || ! -f "$WP_PATH" ]]; then
        SKWD_KEY="$(python3 -c "import json; print(json.load(open('$HOME/.config/skwd-wall-v2/config.json')).get('components',{}).get('wallpaperSelector',{}).get('lastAppliedKey',''))" 2>/dev/null || true)"
        if [[ "$SKWD_KEY" == static:* ]]; then
            FNAME="${SKWD_KEY#static:}"
            if [[ -f "$HOME/Pictures/Wallpapers/$FNAME" ]]; then
                WP_PATH="$HOME/Pictures/Wallpapers/$FNAME"
            fi
        fi
    fi

    # 5. Check Dusky dark_wal fallback
    if [[ -z "$WP_PATH" || ! -f "$WP_PATH" ]]; then
        if [[ -f "$HOME/.config/dusky/settings/dusky_theme/dark_wal" ]]; then
            WP_PATH="$(head -n 1 "$HOME/.config/dusky/settings/dusky_theme/dark_wal" 2>/dev/null | tr -d '[:space:]')"
        fi
    fi
fi

if [[ -z "$WP_PATH" || ! -f "$WP_PATH" ]]; then
    echo "Usage: $0 /path/to/wallpaper.png" >&2
    exit 1
fi

# 1. Apply wallpaper via skwd-wall-still if available (only if not already running with this image)
if command -v skwd-wall-still >/dev/null 2>&1; then
    ALREADY_DISPLAYING="$(ps aux 2>/dev/null | grep "[s]kwd-wall-still" | grep -F "$WP_PATH" | head -n 1 || true)"
    if [[ -z "$ALREADY_DISPLAYING" ]]; then
        MONITOR="$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name // empty' 2>/dev/null || echo "eDP-1")"
        [[ -z "$MONITOR" ]] && MONITOR="eDP-1"
        skwd-wall-still "$MONITOR" "$WP_PATH" --fill-mode fill --persist >/dev/null 2>&1 &
    fi
fi

# 2. Update skwd-wall-v2 config
if [[ -f "$HOME/.config/skwd-wall-v2/config.json" ]]; then
    python3 -c "
import json
path = '$HOME/.config/skwd-wall-v2/config.json'
try:
    with open(path, 'r') as f:
        d = json.load(f)
    fname = '$(basename "$WP_PATH")'
    d.setdefault('components', {}).setdefault('wallpaperSelector', {})['lastAppliedKey'] = f'static:{fname}'
    with open(path, 'w') as f:
        json.dump(d, f, indent=2)
except Exception:
    pass
" 2>/dev/null || true
fi

# 3. Update Dusky state files
mkdir -p "$HOME/.config/dusky/settings/dusky_theme"
printf '%s\n' "$WP_PATH" > "$HOME/.config/dusky/settings/dusky_theme/dark_wal"
printf '%s %s\n' "$WP_PATH" "$WP_PATH" > "$HOME/.config/dusky/settings/dusky_theme/current_image"

# 4. Update Serpantinum state
mkdir -p "$HOME/.local/state/serpantinum"
printf '%s\n' "$WP_PATH" > "$HOME/.local/state/serpantinum/current_wallpaper"
if [[ -f "$HOME/.config/serpantinum/settings.json" ]]; then
    python3 -c "
import json
path = '$HOME/.config/serpantinum/settings.json'
try:
    with open(path, 'r') as f:
        d = json.load(f)
    d['wallpaper'] = '$WP_PATH'
    with open(path, 'w') as f:
        json.dump(d, f, indent=2)
except Exception:
    pass
" 2>/dev/null || true
fi

# 5. Update iNiR config & state
mkdir -p "$HOME/.local/state/quickshell/user/generated/wallpaper"
printf '%s\n' "$WP_PATH" > "$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"
if [[ -f "$HOME/.config/inir/config.json" ]]; then
    python3 -c "
import json
path = '$HOME/.config/inir/config.json'
try:
    with open(path, 'r') as f:
        d = json.load(f)
    d.setdefault('background', {})['wallpaperPath'] = '$WP_PATH'
    with open(path, 'w') as f:
        json.dump(d, f, indent=4)
except Exception:
    pass
" 2>/dev/null || true
fi

# 6. Run Matugen to re-generate theme palettes for all shells & apps
if command -v matugen >/dev/null 2>&1; then
    matugen --source-color-index=0 --mode=dark image "$WP_PATH" >/dev/null 2>&1 || true
fi

echo "[sync_wallpaper] Synchronized successfully with: $WP_PATH"
