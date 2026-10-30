#!/usr/bin/env bash
ACTIVE_SHELL="$(cat "$HOME/.local/state/dusky/active_shell" 2>/dev/null || echo "dusky")"

case "$ACTIVE_SHELL" in
    serpantinum)
        exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle launcher
        ;;
    inir*)
        exec inir overview toggle
        ;;
    *)
        pkill -x rofi 2>/dev/null || true
        exec dusky-run rofi -show drun
        ;;
esac
