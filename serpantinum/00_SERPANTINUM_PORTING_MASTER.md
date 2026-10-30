# Serpantinum Porting Playbook for Dusky Linux

This document is an exhaustive, production-grade guide designed for any developer or AI agent to port **Serpantinum** onto a pristine installation of Dusky Linux (Arch Linux + Hyprland Lua) with identical design, seamless integration, and zero conflicts.

---

## 1. Architecture Overview

- **Host Environment**: Arch Linux, Hyprland (configured via Lua at `~/.config/hypr/source/` and `~/.config/hypr/edit_here/source/`).
- **Target Location**: `~/.config/quickshell/` (Root Quickshell configuration).
- **Core Components**:
  - `Main.qml` / `shell.qml`: Core window manager and surface loader.
  - `bar/Bar.qml`: Dynamic panel (top/bottom/left/right) with system modules.
  - `dock/Dock.qml`: macOS/iOS-style animated bottom application dock.
  - `popouts/`: Popout drawers for System/Control Center, Volume Mixer, Music & Equalizer, Calendar, and Desktop Context Menu.
  - `launcher/`: Spotlight-style app search and clipboard manager.
  - `lock/`: Ext-session-lock Wayland lockscreen with PAM authentication.
  - `guide/`: Settings & Control Center (`guide/settings/SettingsMain.qml`, Digital Wellbeing).
  - `scripts/`: Shell management scripts (`qs_manager.sh`, `lock.sh`, `settings.sh`, `caching.sh`).

---

## 2. Dependencies Checklist

Ensure the following packages are present:
```bash
sudo pacman -S --needed quickshell playerctl brightnessctl cava jq libnotify wireplumber pipewire socat
```

---

## 3. Installation Step-by-Step

### Step 3.1: Deploying the Files
Clone or extract the Serpantinum repository directly into `~/.config/quickshell/`:
```bash
mkdir -p ~/.config/quickshell
cp -r /path/to/serpantinum_source/* ~/.config/quickshell/
chmod +x ~/.config/quickshell/scripts/*.sh
```

### Step 3.2: Configuration State Setup
Create the configuration directory and ensure the default settings disable the internal wallpaper daemon so `skwd-wall-v2` retains ownership:
```bash
mkdir -p ~/.config/serpantinum ~/.local/state/serpantinum/focustime
cat << 'EOF' > ~/.config/serpantinum/settings.json
{
  "bar": { "enabled": true, "position": "top", "autohide": false },
  "dock": { "enabled": true },
  "widgets": { "enabled": true },
  "notifications": { "enabled": true },
  "launcher": { "enabled": true },
  "lock": { "enabled": true },
  "general": { "focusDaemonEnabled": true },
  "wallpaper": { "enabled": false }
}
EOF
```

---

## 4. Critical Bug Fixes & Dusky Adaptations

### Bug 1: Coffee Mode Hold Audio Loop TypeError
- **File**: `~/.config/quickshell/reusables/fillbutton/FillButton.qml`
- **Issue**: Calling `Sounds.playSfxLoop("...")` crashes with `TypeError: Property 'playSfxLoop' of object is not a function`.
- **Fix**: Guard the call and use `Sounds.playUntilStopped("reusables/fillbutton/charge_loop.wav", 0.6, false)` with `isHeldTriggered` flag.

### Bug 2: Coffee Duration Picker Menu Hit-Testing
- **File**: `~/.config/quickshell/guide/battery/BatteryTabState.qml`
- **Issue**: The dropdown menu is nested within a 73px tall item; clicks outside this 73px container fail Qt Quick hit-testing.
- **Fix**: Reparent `coffeePickerCard` and its backdrop dismisser to `view.panel` using `mapToItem(view.panel, 0, 0)` coordinates.

### Bug 3: Digital Wellbeing Read-Only Filesystem Crash
- **File**: `~/.config/quickshell/guide/wellbeing/focus_daemon.py`
- **Issue**: `focus_daemon.py` attempted to write to `/run/user/1000/serpantinum`, which is mounted read-only in sandbox or container environments, throwing `OSError: [Errno 30] Read-only file system`.
- **Fix**: Implement a resilient directory discovery helper:
  1. Probe `/run/user/1000/serpantinum` (if writable).
  2. Fallback to `/tmp/serpantinum/focustime`.
  3. Mirror state to persistent `~/.local/state/serpantinum/focustime/app_time.json`.

### Bug 4: Hyprland Instance Signature Detection
- **File**: `~/.config/quickshell/guide/wellbeing/focus_daemon.py`
- **Issue**: If `HYPRLAND_INSTANCE_SIGNATURE` is unexported in the daemon's environment, `hyprctl activewindow -j` fails silently and records 0 minutes.
- **Fix**: Automatically probe `/run/user/1000/hypr/` for active sockets and export `HYPRLAND_INSTANCE_SIGNATURE` at startup, with a 5-second polling fallback.

### Bug 5: Duplicate Bars on Super + Escape
- **File**: `~/user_scripts/hypr/smart_sidebar.sh`
- **Issue**: Calling `serpantinum msg toggle system` triggered `ensure_daemon()` in the CLI wrapper. If `/tmp/serpantinumd.pid` was absent, `ensure_daemon()` spawned a second `serpantinumd start` daemon, resulting in 2 stacked Serpantinum bars.
- **Fix**: Changed `smart_sidebar.sh` to call `bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle system` directly, dispatching via `quickshell ipc call main handleCommand toggle system` with zero process duplication.

### Bug 6: Direct Wallpaper Redirection
- **File**: `~/.config/quickshell/scripts/qs_manager.sh`
- **Issue**: Serpantinum's internal wallpaper picker attempted to generate thumbnails and manage the desktop layer.
- **Fix**: In `qs_manager.sh` action handler for `wallpaper`, execute `exec /usr/bin/skwd-wall-v2` directly.

---

## 5. Wallpaper & Theming Coordination (`skwd-wall-v2`)

To prevent Serpantinum from opening conflicting wallpaper managers (e.g. `dusky-paper`):
- Wire `ThemeWallpaperPreview.qml` and `DesktopMenu.qml` to invoke `skwd-wall-v2`:
  ```qml
  Quickshell.execDetached(["bash", "-c", "skwd-wall-v2 2>/dev/null || skwd-wall 2>/dev/null"]);
  ```
- Wallpaper preview reading: Read current wallpaper path from `~/.config/skwd-wall-v2/config.json` or `pgrep -a skwd-wall-still`.

---

## 6. Hyprland Layer Rules & Blur
Add the following to `~/.config/hypr/edit_here/source/window_rules.lua`:
```lua
hl.layer_rule({
    name = "quickshell_bar_blur",
    match = { namespace = "quickshell" },
    blur = true,
    blur_popups = true,
    xray = true,
    ignore_alpha = 0.54
})
hl.layer_rule({
    name = "quickshell_popouts_blur",
    match = { namespace = "qs-master" },
    blur = true,
    blur_popups = true,
    xray = true,
    ignore_alpha = 0.54
})
hl.layer_rule({
    name = "quickshell_dock_blur",
    match = { namespace = "qs-dock" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})
```

---

## 7. Lifecycle & Process Management

- **Start**:
  ```bash
  serpantinumd start &
  bash ~/.config/quickshell/guide/wellbeing/launch_daemon.sh &
  ```
- **Stop**:
  ```bash
  killall -9 quickshell 2>/dev/null || true
  pkill -9 -f "serpantinumd" 2>/dev/null || true
  pkill -9 -f "focus_daemon.py" 2>/dev/null || true
  ```
