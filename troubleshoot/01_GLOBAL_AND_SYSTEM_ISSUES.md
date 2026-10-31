# Global & System Troubleshooting Guide

This document details cross-cutting system defects, power/sleep lifecycle traps, Wayland protocol conflicts, and Hyprland integration solutions affecting all shells.

---

## G-01: Quickshell Quits After Prolonged Laptop Lid Close

* **Status:** `[FIXED]`
* **Affected Components:** Laptop lid switch, sleep/suspend lifecycle, `serpantinumd`, Hyprland `keybinds.lua`
* **Symptoms:**
  - Closing the laptop lid for an extended period (suspend/sleep) causes Quickshell to disappear completely.
  - Upon unlocking or opening the lid, the desktop is empty (no top bar, no dock, no widgets).
  - `ps aux | grep quickshell` returns empty.

### Root Cause Analysis
Two distinct root causes trigger this failure:
1. **Wayland `ext-session-lock-v1` Protocol Collision:**
   - On lid close, `keybinds.lua` was executing both `smart_lock.sh` (which invokes Quickshell's `WlSessionLock`) AND `loginctl lock-session` (which causes `hypridle` to launch `hyprlock`).
   - According to the Wayland `ext-session-lock-v1` specification, **only one client may hold a session lock at any time**. When a second client calls `get_ext_session_lock`, the Wayland compositor is mandated to raise a fatal protocol error and terminate the client immediately.
   - Hyprland terminated Quickshell with a protocol error when `hyprlock` launched alongside it.
2. **Missing Watchdog / Single-Run Daemon:**
   - In `serpantinumd`, Quickshell was run inside a single wait loop. If Quickshell exited for any reason (DPMS display power-off, suspend/resume GPU re-initialization), `serpantinumd` exited immediately.
   - Neither `serpantinumd` nor Hyprland had a wake-up watchdog to ensure the shell was re-spawned upon resume.

### Solution & Remediation
1. **Decouple Lid Switch Lock in `~/.config/hypr/edit_here/source/keybinds.lua`:**
   Delegate session locking solely to `loginctl lock-session`. Hypridle coordinates the screen lock cleanly without concurrent lock invocations.
   ```lua
   hl.bind(
       "switch:on:Lid Switch",
       function()
           hl.exec_cmd("pidof hyprlock || loginctl lock-session")
       end,
       { description = "Lock Session on Lid Close", locked = true }
   )
   ```
2. **Add Shell Watchdog on Lid Wake (`switch:off:Lid Switch`):**
   When the lid is opened, wake the display and immediately ensure the active shell is alive:
   ```lua
   hl.bind(
       "switch:off:Lid Switch",
       function()
           hl.dispatch(hl.dsp.dpms({ action = "enable" }))
           hl.exec_cmd("brightnessctl -r")
           hl.exec_cmd(os.getenv("HOME") .. "/user_scripts/hypr/dusky_shell_switch.sh --ensure-running")
       end,
       { description = "Wake Display & Ensure Active Shell on Lid Open", locked = true }
   )
   ```
3. **Resilient Respawn Loop in `~/.local/bin/serpantinumd`:**
   Wrap Quickshell invocation in a persistent loop that only terminates when explicitly stopped:
   ```bash
   while [ "$CLEANUP_DONE" = false ]; do
       setsid quickshell -p "$MAIN_QML" </dev/null >/dev/null 2>&1 9>&- &
       QS_PID=$!
       while kill -0 "$QS_PID" 2>/dev/null; do
           wait "$QS_PID" 2>/dev/null
       done
       [ "$CLEANUP_DONE" = true ] && break
       sleep 1
   done
   ```
4. **Implement `--ensure-running` in `~/user_scripts/hypr/dusky_shell_switch.sh`:**
   Checks if the active shell process (`quickshell`, `qs`, or `waybar`) is running. If absent, respawns the designated shell cleanly.

### Testing & Verification
```bash
# 1. Verify syntax
luac -p ~/.config/hypr/edit_here/source/keybinds.lua

# 2. Test ensure-running when shell is dead
pkill -9 -f "quickshell.*[sS]hell\.qml"
~/user_scripts/hypr/dusky_shell_switch.sh --ensure-running
sleep 2
ps aux | grep -E "quickshell|qs" | grep -v grep
```

---

## G-02: Hyprland Keybinding Collisions & Duplicate Binds

* **Status:** `[FIXED]`
* **Affected Components:** `~/.config/hypr/edit_here/source/keybinds.lua`, `bundle/templates/hyprland_keybinds_snippet.lua`
* **Symptoms:**
  - Pressing `SUPER + SPACE`, `ALT + SPACE`, `SUPER + M`, or `SUPER + V` launches multiple conflicting utilities simultaneously (e.g. both Rofi and Serpantinum launcher).
  - `hyprctl binds` lists the same shortcut bound multiple times.

### Root Cause Analysis
Dusky Linux ships default bindings in `~/.config/hypr/source/keybinds.lua`. When multi-shell dispatchers are merged into `edit_here/source/keybinds.lua` using `hl.bind()` without first unbinding the previous shortcut, Hyprland registers BOTH bindings. In Hyprland, multiple bindings on the same key trigger sequentially.

### Solution & Remediation
Prepend `pcall(hl.unbind, ...)` before each `hl.bind()` call in all snippets and configurations. Wrap in `pcall` so that if the binding does not exist, it fails silently without aborting config loading:
```lua
-- Universal Control Center (Super + Space)
pcall(hl.unbind, "SUPER + SPACE")
pcall(hl.unbind, "SUPER, SPACE")
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_control_center.sh"),
    { description = "System Menu", submap_universal = true }
)
```

---

## G-03: Missing Matugen Input Templates

* **Status:** `[FIXED]`
* **Affected Components:** `~/.config/matugen/config.toml`, `bundle/templates/`
* **Symptoms:**
  - Running `matugen image <wallpaper>` fails with an error:
    `Error: Template input file does not exist: ~/.config/matugen/templates/current-wallpaper.txt` or `shell-switcher.css`.

### Root Cause Analysis
The Matugen configuration snippet in `templates/matugen_config_snippet.toml` registered `[templates.serpantinum_wallpaper]` and `[templates.shell_switcher]`, pointing to input files in `~/.config/matugen/templates/`. However, those two input template files were omitted from the bundle repository, causing fresh installations to fail validation.

### Solution & Remediation
1. Added `current-wallpaper.txt` and `shell-switcher.css` to `bundle/templates/`.
2. Updated `safe_config_merger.py` to automatically copy all template files from `bundle/templates/` into `~/.config/matugen/templates/` and `~/.config/quickshell/assets/matugen/templates/` before appending `config.toml`.

---

## G-04: `sync_wallpaper.sh` Reading Stale Wallpaper

* **Status:** `[FIXED]`
* **Affected Components:** `~/user_scripts/hypr/sync_wallpaper.sh`, `bundle/scripts/sync_wallpaper.sh`
* **Symptoms:**
  - Running `sync_wallpaper.sh` without arguments reverts the wallpaper to an older image or writes stale tokens to Matugen.
  - The desktop wallpaper flickers unnecessarily.

### Root Cause Analysis
`sync_wallpaper.sh` read `~/.config/dusky/settings/dusky_theme/dark_wal` as its primary fallback. If the user changed wallpaper via `skwd-wall-v2` or `skwd-wall-still`, `dark_wal` was not updated, causing the script to reapply the outdated wallpaper.

### Solution & Remediation
1. Prioritize active running process inspection:
   ```bash
   CURRENT_RUNNING="$(ps aux 2>/dev/null | grep "[s]kwd-wall-still" | grep -oP '/home/[^ "]+' | head -n 1 || true)"
   ```
2. Query `awww query` and `~/.cache/current_wallpaper` before checking `dark_wal`.
3. Add anti-flicker guard: check if `skwd-wall-still` is already displaying the target image; if so, skip relaunching.

---

## G-05: Shell Not Autostarting After Reboot

* **Status:** `[FIXED]`
* **Affected Components:** `~/.config/hypr/edit_here/source/autostart.lua`
* **Symptoms:**
  - After rebooting, the system launches in plain Dusky with Waybar, even if the user was using Serpantinum or iNiR before rebooting.

### Root Cause Analysis
The shell state is preserved in `~/.local/state/dusky/active_subshell`, and `dusky_shell_switch.sh --autostart` exists to restore it. However, on fresh installations, this command was not registered in `autostart.lua`.

### Solution & Remediation
Ensure `autostart.lua` includes:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("$HOME/user_scripts/hypr/dusky_shell_switch.sh --autostart")
end)
```

---

## G-06: Workspace Switcher Drops Focus to Workspace 2

* **Status:** `[FIXED]`
* **Affected Components:** `dusky_shell_switcher.py`, `dusky_shell_switch.sh`
* **Symptoms:**
  - Selecting a shell in the GTK switcher menu changes the active workspace from 1 to 2.

### Root Cause Analysis
With Hyprland's `focus_on_close = 0`, destroying full-screen layer-shell surfaces transfers focus to the next available surface (Workspace 2). Additionally, legacy `hyprctl dispatch workspace N` fails on Hyprland 0.55+ with a Lua parse error.

### Solution & Remediation
1. Pre-capture active workspace in `dusky_shell_switcher.py` before unmapping.
2. Emit modern Lua commands in `dusky_shell_switch.sh`:
   `hyprctl dispatch "hl.dsp.focus({ workspace = \"${TARGET_WS}\" })"`
3. Execute deferred focus pulses at 150ms, 500ms, and 1000ms.

---

## G-07: Ghost Shells Running Simultaneously (`qs` vs `quickshell`)

* **Status:** `[FIXED]`
* **Affected Components:** `dusky_shell_switch.sh`
* **Symptoms:**
  - Waffle (iNiR) and Serpantinum bars and docks appear on screen at the same time.

### Root Cause Analysis
iNiR executes via `/usr/bin/qs`, while Serpantinum executes via `quickshell`. Standard `pkill -f quickshell.*inir` missed the `/usr/bin/qs` binary.

### Solution & Remediation
All teardown routines in `dusky_shell_switch.sh` use dual-matching patterns:
```bash
pkill -9 -f "(/usr/bin/)?(qs|quickshell).*(inir)" 2>/dev/null || true
pkill -9 -f "(/usr/bin/)?(qs|quickshell).*[sS]hell\.qml" 2>/dev/null || true
```
