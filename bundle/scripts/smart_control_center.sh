#!/usr/bin/env bash
ACTIVE_SHELL="$(cat "$HOME/.local/state/dusky/active_shell" 2>/dev/null || echo "dusky")"

case "$ACTIVE_SHELL" in
    serpantinum)
        exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle syspanel
        ;;
    inir*)
        SUBSHELL="$(cat "$HOME/.local/state/dusky/active_subshell" 2>/dev/null || echo "")"
        if [[ "$SUBSHELL" == "inir-waffle" ]]; then
            exec inir wactionCenter toggle
        else
            exec inir controlPanel toggle
        fi
        ;;
    *)
        exec gdbus call --session --dest com.github.dusky.controlcenter --object-path /com/github/dusky/controlcenter --method org.freedesktop.Application.Activate "{}"
        ;;
esac
