#!/usr/bin/env bash
ACTIVE_SHELL="$(cat "$HOME/.local/state/dusky/active_shell" 2>/dev/null || echo "dusky")"

case "$ACTIVE_SHELL" in
    serpantinum)
        exec quickshell -p "$HOME/.config/quickshell/shell.qml" ipc call floating toggle
        ;;
    inir*)
        exec inir sidebarRight toggle
        ;;
    *)
        # Dusky native: leave fullscreen
        exec hyprctl dispatch fullscreen 0
        ;;
esac
