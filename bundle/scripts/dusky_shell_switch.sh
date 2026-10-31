#!/usr/bin/env bash
# ==============================================================================
# DUSKY UNIVERSAL SHELL SWITCHER - CORE ENGINE
# ==============================================================================
# Seamless, clean switching between desktop shells:
# 1. Dusky Native (Waybar + Mako + Rofi)
# 2. Serpantinum (Quickshell Bar, Dock, Widgets)
# 3. iNiR Desktop Shell (iRiS Dynamic Island, Material ii, Waffle)
# Guarantees zero duplicate processes, zero service conflicts, zero lock leaks.
# ==============================================================================

set -euo pipefail

LOCK_DIR="/tmp/dusky_shell_switch.lock"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dusky"
STATE_FILE="${STATE_DIR}/active_shell"
SUBSHELL_FILE="${STATE_DIR}/active_subshell"
LEGACY_BAR_STATE="${STATE_DIR}/active_bar"

SERPANTINUM_SETTINGS="${XDG_CONFIG_HOME:-$HOME/.config}/serpantinum/settings.json"
INIR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir"
INIR_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/inir/config.json"
GUI_SWITCHER="${HOME}/user_scripts/hypr/dusky_shell_switcher.py"

# Capture target workspace upfront: passed as $2 or queried from Hyprland
TARGET_WS="${2:-}"
if [[ -z "$TARGET_WS" ]]; then
    TARGET_WS="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty' 2>/dev/null || true)"
fi

restore_workspace() {
    if [[ -n "${TARGET_WS:-}" && "$TARGET_WS" =~ ^[0-9]+$ ]]; then
        hyprctl dispatch "hl.dsp.focus({ workspace = \"${TARGET_WS}\" })" >/dev/null 2>&1 \
            || hyprctl dispatch workspace "$TARGET_WS" >/dev/null 2>&1 || true
        (
            sleep 0.15
            hyprctl dispatch "hl.dsp.focus({ workspace = \"${TARGET_WS}\" })" >/dev/null 2>&1 \
                || hyprctl dispatch workspace "$TARGET_WS" >/dev/null 2>&1 || true
            sleep 0.5
            hyprctl dispatch "hl.dsp.focus({ workspace = \"${TARGET_WS}\" })" >/dev/null 2>&1 \
                || hyprctl dispatch workspace "$TARGET_WS" >/dev/null 2>&1 || true
            sleep 1.0
            hyprctl dispatch "hl.dsp.focus({ workspace = \"${TARGET_WS}\" })" >/dev/null 2>&1 \
                || hyprctl dispatch workspace "$TARGET_WS" >/dev/null 2>&1 || true
        ) </dev/null >/dev/null 2>&1 &
        disown || true
    fi
}

mkdir -p "$STATE_DIR"

notify() {
    local title="$1"
    local msg="$2"
    local icon="${3:-preferences-desktop-theme}"
    if command -v notify-send &>/dev/null; then
        notify-send -a "Shell Switcher" -i "$icon" -r 9944 "$title" "$msg" 2>/dev/null || true
    fi
}

get_active_shell() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE" | tr -d '[:space:]'
    else
        echo "dusky"
    fi
}

save_active_shell() {
    local shell="$1"
    local subshell="${2:-$shell}"
    printf '%s\n' "$shell" > "$STATE_FILE"
    printf '%s\n' "$subshell" > "$SUBSHELL_FILE" 2>/dev/null || true
    if [[ "$shell" == "dusky" ]]; then
        printf 'waybar\n' > "$LEGACY_BAR_STATE" 2>/dev/null || true
    else
        printf '%s\n' "$shell" > "$LEGACY_BAR_STATE" 2>/dev/null || true
    fi
}

kill_serpantinum_all() {
    pkill -9 -f "quickshell.*[sS]hell\.qml" 2>/dev/null || true
    pkill -9 -f "qs.*[sS]hell\.qml" 2>/dev/null || true
    pkill -9 -f "serpantinumd" 2>/dev/null || true
    pkill -9 -f "focus_daemon.py" 2>/dev/null || true
    pkill -9 -f "cava.*quickshell" 2>/dev/null || true
    pkill -9 -f "sys_fetcher.sh" 2>/dev/null || true
    pkill -9 -f "current_focus.sh" 2>/dev/null || true
    pkill -9 -f "art_fetch.sh" 2>/dev/null || true
    pkill -9 -f "inotifywait.*serpantinum" 2>/dev/null || true
    pkill -9 -f "inotifywait.*backlight" 2>/dev/null || true
    rm -f /tmp/serpantinumd.pid /tmp/serpantinumd.lock 2>/dev/null || true
}

kill_inir_all() {
    inir kill 2>/dev/null || true
    pkill -9 -f "qs.*inir" 2>/dev/null || true
    pkill -9 -f "quickshell.*inir" 2>/dev/null || true
    pkill -9 -f "dev_hot_reload.py" 2>/dev/null || true
    pkill -9 -f "keyboard_lock_state_daemon.py" 2>/dev/null || true
    pkill -9 -f "inir_super_overview" 2>/dev/null || true
    pkill -9 -f "innertube" 2>/dev/null || true
    pkill -9 -f "applycolor.sh" 2>/dev/null || true
}

kill_dusky_all() {
    killall -9 waybar 2>/dev/null || true
    pkill -9 -x waybar 2>/dev/null || true

    systemctl --user mask mako.service 2>/dev/null || true
    systemctl --user stop mako.service 2>/dev/null || true
    killall -9 mako 2>/dev/null || true
    pkill -9 -x mako 2>/dev/null || true
}

apply_dusky() {
    # 1. Terminate all foreign shells
    kill_serpantinum_all
    kill_inir_all

    # 2. Unmask and start Dusky Mako notification daemon
    systemctl --user unmask mako.service 2>/dev/null || true
    systemctl --user start mako.service --no-block 2>/dev/null || pgrep -x mako >/dev/null || setsid nohup mako </dev/null >/dev/null 2>&1 &
    disown || true

    # 3. Start Dusky Waybar
    if ! pgrep -x waybar >/dev/null; then
        setsid nohup waybar </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    save_active_shell "dusky" "dusky"

    if [[ -x "$HOME/user_scripts/hypr/sync_wallpaper.sh" ]]; then
        setsid nohup "$HOME/user_scripts/hypr/sync_wallpaper.sh" </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    restore_workspace

    notify "Dusky Native Active" "Waybar and Mako notifications active" "preferences-desktop-display"
}

apply_serpantinum() {
    # 1. Stop all Dusky and iNiR components; mask mako
    kill_dusky_all
    kill_inir_all
    kill_serpantinum_all

    # 2. Ensure Serpantinum components are enabled in settings.json
    if [[ -f "$SERPANTINUM_SETTINGS" ]] && command -v jq &>/dev/null; then
        local tmp
        tmp=$(mktemp)
        jq '.bar.enabled = true | .dock.enabled = true | .widgets.enabled = true | .notifications.enabled = true | .launcher.enabled = true | .clipboard.enabled = true | .lock.enabled = true | .general.focusDaemonEnabled = true | if (.wallpaper | type) == "object" then .wallpaper = "" else . end' \
           "$SERPANTINUM_SETTINGS" > "$tmp" 2>/dev/null && mv -f "$tmp" "$SERPANTINUM_SETTINGS"
    fi

    save_active_shell "serpantinum" "serpantinum"

    if [[ -x "$HOME/user_scripts/hypr/sync_wallpaper.sh" ]]; then
        setsid nohup "$HOME/user_scripts/hypr/sync_wallpaper.sh" </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    # 3. Launch serpantinumd and focus daemon fully detached
    setsid nohup serpantinumd start </dev/null >/dev/null 2>&1 &
    disown || true

    if [[ -f "$HOME/.config/quickshell/guide/wellbeing/launch_daemon.sh" ]]; then
        setsid nohup bash "$HOME/.config/quickshell/guide/wellbeing/launch_daemon.sh" </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    restore_workspace

    # 4. Notify
    (
        sleep 1.2
        notify "Serpantinum Active" "Serpantinum Bar, Dock & Widgets active" "preferences-desktop-theme"
    ) </dev/null >/dev/null 2>&1 &
    disown || true
}

apply_inir() {
    local family="${1:-iris}"

    # 1. Stop Dusky and Serpantinum components; mask mako
    kill_dusky_all
    kill_serpantinum_all

    # 2. Ensure iNiR config uses desired panelFamily and skwd-wall background
    if [[ -f "$INIR_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp
        tmp=$(mktemp)
        jq --arg fam "$family" '.panelFamily = $fam | .modules.background = true' \
           "$INIR_CONFIG" > "$tmp" 2>/dev/null && mv -f "$tmp" "$INIR_CONFIG"
    fi

    save_active_shell "inir" "inir-${family}"

    if [[ -x "$HOME/user_scripts/hypr/sync_wallpaper.sh" ]]; then
        setsid nohup "$HOME/user_scripts/hypr/sync_wallpaper.sh" </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    # 3. Check if iNiR is already running
    if pgrep -f "qs.*inir" >/dev/null 2>&1 || pgrep -f "quickshell.*inir" >/dev/null 2>&1; then
        # Dynamically switch family via IPC
        inir panelFamily set "$family" 2>/dev/null || true
    else
        # Launch iNiR detached via inir run --daemon
        setsid nohup inir run --daemon </dev/null >/dev/null 2>&1 &
        disown || true
    fi

    restore_workspace

    local pretty_family="iRiS Island"
    case "$family" in
        ii) pretty_family="Material ii" ;;
        waffle) pretty_family="Waffle (Win11)" ;;
        iris) pretty_family="iRiS (Dynamic Island)" ;;
    esac

    (
        sleep 1.2
        notify "iNiR Shell Active" "Panel Family: ${pretty_family}" "preferences-desktop-wallpaper"
    ) </dev/null >/dev/null 2>&1 &
    disown || true
}

ACTION="${1:-}"

# GUI menu doesn't need the execution lock
if [[ "$ACTION" == "--menu" || "$ACTION" == "menu" || "$ACTION" == "" ]]; then
    if [[ -x "$GUI_SWITCHER" ]]; then
        exec python3 "$GUI_SWITCHER"
    else
        apply_dusky
    fi
    exit 0
fi

if [[ "$ACTION" == "--status" || "$ACTION" == "status" ]]; then
    get_active_shell
    exit 0
fi

# Acquire lock via atomic directory creation
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    # If lock is stale (older than 10s), break it
    if [[ $(find "$LOCK_DIR" -maxdepth 0 -mmin +0.15 2>/dev/null) ]]; then
        rm -rf "$LOCK_DIR" 2>/dev/null || true
        mkdir "$LOCK_DIR" 2>/dev/null || exit 0
    else
        exit 0
    fi
fi
trap 'rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT INT TERM

case "$ACTION" in
    --dusky|dusky)
        apply_dusky
        ;;
    --serpantinum|serpantinum)
        apply_serpantinum
        ;;
    --inir|inir)
        apply_inir "iris"
        ;;
    --inir-iris|inir-iris|iris)
        apply_inir "iris"
        ;;
    --inir-ii|inir-ii|ii)
        apply_inir "ii"
        ;;
    --inir-waffle|inir-waffle|waffle)
        apply_inir "waffle"
        ;;
    --toggle|toggle)
        CURRENT=$(get_active_shell)
        case "$CURRENT" in
            dusky) apply_serpantinum ;;
            serpantinum) apply_inir "iris" ;;
            *) apply_dusky ;;
        esac
        ;;
    --autostart|autostart)
        CURRENT=$(get_active_shell)
        SUBSHELL="$(cat "$SUBSHELL_FILE" 2>/dev/null || echo "$CURRENT")"
        case "$SUBSHELL" in
            serpantinum) apply_serpantinum ;;
            inir-ii) apply_inir "ii" ;;
            inir-waffle) apply_inir "waffle" ;;
            inir*) apply_inir "iris" ;;
            *) apply_dusky ;;
        esac
        ;;
    --ensure-running|ensure-running)
        CURRENT=$(get_active_shell)
        SUBSHELL="$(cat "$SUBSHELL_FILE" 2>/dev/null || echo "$CURRENT")"
        IS_RUNNING=false
        case "$CURRENT" in
            serpantinum)
                if pgrep -f "[q]uickshell.*[sS]hell\.qml" >/dev/null 2>&1 || pgrep -f "[q]s.*[sS]hell\.qml" >/dev/null 2>&1; then
                    IS_RUNNING=true
                fi
                ;;
            inir)
                if pgrep -f "[q]s.*inir" >/dev/null 2>&1 || pgrep -f "[q]uickshell.*inir" >/dev/null 2>&1; then
                    IS_RUNNING=true
                fi
                ;;
            dusky)
                if pgrep -x "waybar" >/dev/null 2>&1; then
                    IS_RUNNING=true
                fi
                ;;
        esac
        if [[ "$IS_RUNNING" == false ]]; then
            echo "[dusky_shell_switch] Active shell ($SUBSHELL) is not running. Respawning..."
            case "$SUBSHELL" in
                serpantinum) apply_serpantinum ;;
                inir-ii) apply_inir "ii" ;;
                inir-waffle) apply_inir "waffle" ;;
                inir*) apply_inir "iris" ;;
                *) apply_dusky ;;
            esac
        fi
        ;;
    *)
        echo "Usage: $(basename "$0") [--dusky|--serpantinum|--inir|--inir-iris|--inir-ii|--inir-waffle|--toggle|--autostart|--ensure-running|--status|--menu]"
        exit 1
        ;;
esac
