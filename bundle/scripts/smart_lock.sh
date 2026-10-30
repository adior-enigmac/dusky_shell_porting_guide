#!/usr/bin/env bash
ACTIVE_SHELL="$(cat "$HOME/.local/state/dusky/active_shell" 2>/dev/null || echo "dusky")"

case "$ACTIVE_SHELL" in
    serpantinum)
        exec bash "$HOME/.config/quickshell/scripts/lock.sh" "$@"
        ;;
    inir*)
        exec inir lock activate
        ;;
    *)
        # Dusky native hyprlock
        WALLPAPER=$(awww query 2>/dev/null | grep -oP 'image: \K.*' | head -1)
        [ -n "$WALLPAPER" ] && cp "$WALLPAPER" "$HOME/.cache/current_wallpaper" 2>/dev/null || true
        exec hyprlock "$@"
        ;;
esac
