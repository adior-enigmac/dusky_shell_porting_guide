#!/usr/bin/env bash
ACTIVE_SHELL="$(cat "$HOME/.local/state/dusky/active_shell" 2>/dev/null || echo "dusky")"

case "$ACTIVE_SHELL" in
    serpantinum)
        exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle clipboard
        ;;
    inir*)
        exec inir clipboard toggle
        ;;
    *)
        STATE_FILE="$HOME/.config/dusky/settings/clipboard_state"
        USE_TERMINAL=1
        if [[ -f "$STATE_FILE" ]]; then
            if grep -q "False" "$STATE_FILE"; then
                USE_TERMINAL=0
            fi
        fi
        if (( USE_TERMINAL )); then
            pkill -15 -f '^foot.*terminal_clipboard' 2>/dev/null && exit 0
            exec foot --app-id=terminal_clipboard.sh "$HOME/user_scripts/clipboard/terminal_clipboard.sh"
        else
            pkill -x rofi 2>/dev/null || true
            exec rofi -modi "clipboard:$HOME/user_scripts/rofi/rofi_clipboard.sh" -show clipboard
        fi
        ;;
esac
