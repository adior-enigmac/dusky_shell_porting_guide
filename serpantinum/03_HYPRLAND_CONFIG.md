# Hyprland Configuration Guide

## Overview

All Hyprland integrations are stored in [`~/.config/hypr/edit_here/`](file:///home/ubaid/.config/hypr/edit_here/), ensuring Dusky's upstream configurations remain clean and untouched.

---

## 1. Keybindings (`edit_here/source/keybinds.lua`)

To avoid colliding with Dusky's default keybinds (`SUPER + W` for wallpaper, `SUPER + B` for browser, `SUPER + C` for IDE, `SUPER + S` for pause, `SUPER + M` for workspace), all Serpantinum actions use the clean `SUPER + CTRL + <KEY>` namespace:

| Shortcut | Action | Command | Purpose |
| :--- | :--- | :--- | :--- |
| `SUPER + CTRL + B` | **Universal Shell Switcher** | `dusky_shell_switcher.py` | Opens the centered Matugen-styled shell selector |
| `SUPER + CTRL + W` | **Widget Redactor** | `serpantinum launch widgetredactor` | Toggles the visual drag-and-drop widget canvas editor |
| `SUPER + CTRL + S` | **Control Center / System Panel** | `serpantinum msg toggle system` | Toggles volume, wifi, bt, power, focus, and shell switcher |
| `SUPER + CTRL + V` | **Audio Mixer Popout** | `serpantinum msg toggle volume` | Toggles Pipewire application stream volume mixer |
| `SUPER + CTRL + M` | **Music Player & Equalizer** | `serpantinum msg toggle music` | Toggles media controls, album artwork, and audio visualizer |
| `SUPER + CTRL + C` | **Calendar & Clock Popout** | `serpantinum msg toggle calendar` | Toggles calendar, upcoming schedule, and weather forecast |

---

## 2. Layer Blur Rules (`edit_here/source/window_rules.lua`)

Hyprland will NOT blur Wayland layer-shell surfaces (such as Quickshell bars and popouts) unless explicitly instructed with `hl.layer_rule`.

The following layer rules are configured:

```lua
-- 1. Quickshell Bar
hl.layer_rule({
    name = "quickshell_bar_blur",
    match = { namespace = "^quickshell$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.0
})

-- 2. Quickshell Master Popouts (Volume, Syspanel, Music, Calendar)
hl.layer_rule({
    name = "quickshell_master_blur",
    match = { namespace = "^qs-master$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.0
})

-- 3. Animated Bottom Dock
hl.layer_rule({
    name = "quickshell_dock_blur",
    match = { namespace = "^qs-dock$" },
    blur = true,
    ignore_alpha = 0.0
})

-- 4. Desktop Context Menu & Tray Menus
hl.layer_rule({
    name = "quickshell_menus_blur",
    match = { namespace = "^(desktopmenu|dockappmenu|traymenu|sidemusic)$" },
    blur = true,
    ignore_alpha = 0.0
})

-- 5. Spotlight Launcher & Clipboard Manager
hl.layer_rule({
    name = "quickshell_launcher_blur",
    match = { namespace = "^(qs-applauncher|qs-clipboard)$" },
    blur = true,
    dim_around = true,
    ignore_alpha = 0.0
})

-- 6. Notification Popups & OSD
hl.layer_rule({
    name = "quickshell_notifications_osd_blur",
    match = { namespace = "^(qs-popups|osd)$" },
    blur = true,
    ignore_alpha = 0.0
})

-- 7. Universal Shell Switcher (Python GTK LayerShell)
hl.layer_rule({
    name = "universal_switcher_blur",
    match = { namespace = "^(dusky-shell-switcher|qs-shell-switcher)$" },
    blur = true,
    dim_around = true,
    ignore_alpha = 0.0
})
```

---

## 3. Autostart (`edit_here/source/autostart.lua`)

The boot sequence guarantees that the active shell profile is initialized deterministically:

```lua
-- --- ACTIVE DESKTOP SHELL (Managed via dusky_shell_switch.sh: Dusky or Serpantinum) ---
hl.exec_cmd("$HOME/user_scripts/hypr/dusky_shell_switch.sh --autostart")

-- --- SERPANTINUM QUICKSHELL DAEMON (Desktop Widgets, Dock, Popouts) ---
hl.exec_cmd("serpantinumd start")
```
