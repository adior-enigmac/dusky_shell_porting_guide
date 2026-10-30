# Dusky Universal Shell Switcher Guide

## Overview

The **Dusky Universal Shell Switcher** provides hot-swappable, collision-free switching between complete desktop environments.

Unlike simple status-bar switchers, this system controls the entire presentation tier:
- **Status Bars**: Waybar vs. Serpantinum Quickshell Bar.
- **Notification Daemons**: Native `mako.service` vs. Quickshell Notification Server (`org.freedesktop.Notifications`).
- **Application Launchers**: Rofi vs. Serpantinum Spotlight Launcher.
- **Screen Lockers**: Dusky `hyprlock` vs. Quickshell Lockscreen & Lock Redactor.
- **Desktop Panels & Docks**: Serpantinum Animated Dock, Desktop Widgets, Audio Mixers, and Quick Actions.

---

## Architecture Components

```
┌────────────────────────────────────────────────────────────────────────┐
│                        USER INVOCATION INTERFACES                       │
│  [SUPER + CTRL + B]  │  System Panel Button (󱂬)  │  Desktop Menu (󱂬)   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│           dusky_shell_switcher.py (GTK3 + GtkLayerShell GUI)            │
│  - Zero Rofi / Quickshell dependency (operates autonomously)           │
│  - Keyboard navigation ([↑/↓], [1/2], [Enter], [Esc])                  │
│  - Matugen Dynamic Theme (~/.config/matugen/generated/shell-switcher.css│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│             dusky_shell_switch.sh (Atomic Backend Engine)              │
│  - flock mutex lock at /tmp/dusky_shell_switch.lock                    │
│  - State persistence at ~/.local/state/dusky/active_shell              │
└───────────────────┬────────────────────────────────┬───────────────────┘
                    │                                │
                    ▼                                ▼
       [DUSKY NATIVE PROFILE]             [SERPANTINUM PROFILE]
       - waybar_toggle.sh --on            - waybar_toggle.sh --off
       - systemctl start mako.service     - systemctl stop mako.service
       - Quickshell Bar / Notifs OFF      - Quickshell Bar / Notifs ON
       - Rofi active                      - Quickshell Spotlight active
```

---

## 1. Profiles

### Profile 1: Dusky Native Shell (`dusky`)
- **Status Bar**: Native Dusky Waybar.
- **Notifications**: Dusky Mako daemon (`mako.service`), fully integrated with Matugen.
- **Launcher**: Native Rofi menus (`rofi-wayland`).
- **Screen Lock**: Dusky native `hyprlock`.
- **Quickshell State**: Bar, Notifications, Launcher, and Lock disabled in `settings.json`; Quickshell daemon remains active in background to render desktop widgets and wallpaper context menus if desired.

### Profile 2: Serpantinum Quickshell (`serpantinum`)
- **Status Bar**: Serpantinum Quickshell Top Bar.
- **Notifications**: Serpantinum Quickshell Notification Server (binds DBus `org.freedesktop.Notifications` with notification center and popups).
- **Launcher**: Serpantinum Spotlight App Launcher (`SUPER + SPACE` or launcher button).
- **Dock**: Quickshell animated floating bottom dock with pin/unpin app management.
- **Desktop Widgets**: Dynamic system dials, CPU/RAM/Battery meters, music lyrics, and notes canvas.
- **Dusky State**: Waybar process safely stopped; Mako service stopped to release the notification bus.

---

## 2. Invocation Methods

1. **Global Hotkey**: Press `SUPER + CTRL + B` to summon the floating centered GUI.
2. **Control Center / System Panel**: Click the `󱂬` quick action button in the system panel (right-click toggles instantly).
3. **Desktop Context Menu**: Right-click wallpaper and select **"Switch Desktop Shell"**.
4. **Terminal CLI**:
   ```bash
   dusky-shell-switch             # Opens GUI switcher
   dusky-shell-ctl --dusky         # Instantly switch to Dusky
   dusky-shell-ctl --serpantinum   # Instantly switch to Serpantinum
   dusky-shell-ctl --toggle        # Flip between active shells
   dusky-shell-ctl --status        # Query active shell name
   ```

---

## 3. Atomic Synchronization & Safety

- **Mutex Locking**: Both `dusky_shell_switch.sh` and `dusky_shell_switcher.py` utilize non-blocking `flock` locks. Rapid double-clicking cannot trigger split-brain states or duplicate background processes.
- **Autostart Consistency**: On session login, `~/.config/hypr/edit_here/source/autostart.lua` calls `dusky_shell_switch.sh --autostart`, which inspects `~/.local/state/dusky/active_shell` and restores the exact environment you last selected.
