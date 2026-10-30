# Universal Smart Dispatchers & Dynamic Keybindings

Dusky Linux uses a unified keybinding architecture. Instead of forcing users to learn separate keyboard shortcuts for every ported shell, all primary system shortcuts route through intelligent shell-aware dispatchers.

---

## 1. Dispatch Architecture

```
User Keybind (e.g. Super + Space)
       │
       ▼
Hyprland Lua Binding (hl.bind)
       │
       ▼
Smart Dispatcher Script (~/user_scripts/hypr/smart_control_center.sh)
       │
       ├──► Active Shell == "dusky"       ──► GDBus GTK Control Center
       ├──► Active Shell == "serpantinum" ──► Quickshell Settings Popout
       └──► Active Shell == "inir*"       ──► inir controlPanel toggle
```

---

## 2. Dispatchers Specification

### 2.1 App Launcher (`smart_launcher.sh`)
- **Shortcut**: `Alt + Space`
- **Routing**:
  - `dusky`: `dusky-run rofi -show drun`
  - `serpantinum`: `bash ~/.config/quickshell/scripts/qs_manager.sh toggle launcher`
  - `inir*`: `inir overview toggle`

### 2.2 Lock Screen (`smart_lock.sh`)
- **Shortcut**: `Super + M` (or lid close trigger)
- **Routing**:
  - `dusky`: `hyprlock`
  - `serpantinum`: `bash ~/.config/quickshell/scripts/lock.sh`
  - `inir*`: `inir lock lock`

### 2.3 Control Center / Quick Settings (`smart_control_center.sh`)
- **Shortcut**: `Super + Space`
- **Routing**:
  - `dusky`: `gdbus call --session --dest com.github.dusky.controlcenter ...`
  - `serpantinum`: `bash ~/.config/quickshell/scripts/qs_manager.sh toggle syspanel` (`qs-master` system panel with sliders, quick actions, power buttons)
  - `inir-waffle`: `inir wactionCenter toggle` (Windows 11 Action Center)
  - `inir-iris` / `inir-ii`: `inir controlPanel toggle` (Iris morph island / Material Control Center)

### 2.4 Sidebar / Popout / Fullscreen (`smart_sidebar.sh`)
- **Shortcut**: `Super + Escape`
- **Routing**:
  - `dusky`: `hyprctl dispatch fullscreen 0` (leaves fullscreen mode safely)
  - `serpantinum`: `quickshell -p ~/.config/quickshell/shell.qml ipc call floating toggle` (toggles Quickactions floating sidebar: Calculator, Timer, Draw, Notes, System Usage)
  - `inir*`: `inir sidebarRight toggle` (toggles right drawer)

### 2.5 Clipboard History (`smart_clipboard.sh`)
- **Shortcut**: `Super + V`
- **Routing**:
  - `dusky`: `foot --app-id=terminal_clipboard.sh ~/user_scripts/clipboard/terminal_clipboard.sh` (or Rofi clipboard depending on `clipboard_state`). `cmd_key_escape()` is fixed to emit `abort`, closing immediately on `ESC`.
  - `serpantinum`: `bash ~/.config/quickshell/scripts/qs_manager.sh toggle clipboard` (Rich spotlight clipboard manager with pinned clips, fuzzy search, ESC dismiss, TopBar button, and Control Center tile)
  - `inir*`: `inir clipboard toggle` (iNiR rich clipboard panel)

---

## 3. Hyprland Lua Configuration Reference

In `~/.config/hypr/source/keybinds.lua`:
```lua
-- Application Launcher
hl.bind(
    "ALT + SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_launcher.sh"),
    { description = "Launch Menu for Apps" }
)

-- Control Center
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_control_center.sh"),
    { description = "System Menu" }
)

-- Lock Screen
hl.bind(
    "SUPER + M",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_lock.sh"),
    { description = "Lock Screen" }
)

-- Sidebar & Leave Fullscreen
hl.bind(
    "SUPER + Escape",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_sidebar.sh"),
    {
        description = "Toggle Sidebar / Leave Fullscreen",
        dont_inhibit = true,
        allow_input_capture = true,
        submap_universal = true,
    }
)

-- Smart Clipboard History
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_clipboard.sh"),
    { description = "Smart Clipboard History (Shell Aware)" }
)
```
