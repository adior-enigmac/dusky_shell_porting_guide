# Dusky Universal Shell Switcher Engine

The Universal Shell Switcher enables instantaneous, conflict-free transitions between installed desktop shells. It consists of a headless CLI engine ([`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh)) and a minimal Wayland LayerShell GUI ([`dusky_shell_switcher.py`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switcher.py)).

---

## 1. Core State & Locking Mechanism

### State Persistence
State is tracked in standard XDG state directories:
- `~/.local/state/dusky/active_shell`: Contains primary active shell (`dusky`, `serpantinum`, or `inir`).
- `~/.local/state/dusky/active_subshell`: Contains specific subshell variant (`dusky`, `serpantinum`, `inir-iris`, `inir-ii`, `inir-waffle`).
- `~/.local/state/dusky/active_bar`: Backward compatibility indicator (`waybar`, `serpantinum`, `inir`).

### Atomic Execution Guard
To prevent race conditions when shortcuts are pressed rapidly, [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh) uses an atomic directory lock (`/tmp/dusky_shell_switch.lock`) with stale-lock breaking (auto-cleared if older than 10 seconds).

---

## 2. CLI Engine Targets

```bash
# Direct shell switching
dusky_shell_switch.sh --dusky           # Switch to Dusky Native
dusky_shell_switch.sh --serpantinum     # Switch to Serpantinum
dusky_shell_switch.sh --inir-iris       # Switch to iNiR (iRiS Island)
dusky_shell_switch.sh --inir-ii         # Switch to iNiR (Material ii)
dusky_shell_switch.sh --inir-waffle     # Switch to iNiR (Windows 11 Waffle)

# Status & Utilities
dusky_shell_switch.sh --status          # Prints current active shell
dusky_shell_switch.sh --toggle          # Cycles to next available shell
dusky_shell_switch.sh --autostart       # Restores previously active shell on login
dusky_shell_switch.sh --menu            # Opens the LayerShell GUI switcher
```

---

## 3. Minimal LayerShell GUI (`dusky_shell_switcher.py`)

- **Tech Stack**: Python 3 + GTK 3 + `GtkLayerShell`.
- **Keyboard Navigation**:
  - `1`, `d`, `D`: Select Dusky Native.
  - `2`, `s`, `S`: Select Serpantinum.
  - `3`, `i`, `I`: Select iNiR (iRiS Island).
  - `4`, `m`, `M`: Select iNiR (Material ii).
  - `5`, `w`, `W`: Select iNiR (Waffle).
  - `Up` / `k` / `Down` / `j`: Arrow navigation.
  - `Enter` / `Space`: Confirm and apply.
  - `Escape` / `q`: Close menu without changes.
- **Theming**: Dynamically styled via Matugen CSS at `~/.config/matugen/generated/shell-switcher.css`, with embedded fallback styling.

---

## 4. Workspace Retention & Hyprland 0.55+ Lua Dispatcher

### The Problem
In Hyprland configurations with `focus_on_close = 0` (such as `~/.config/hypr/source/input.lua:38`), closing a layer-surface window or killing a shell process when no other tiled windows exist on the current workspace causes Hyprland to search window focus history across workspaces. This kicks the user to Workspace 2 (or whichever workspace has an active terminal or editor). Furthermore, legacy `hyprctl dispatch workspace N` fails on Hyprland 0.55+ with syntax error `return hl.dispatch(workspace N)`.

### The Architecture Solution
1. **Pre-Capture**: [`dusky_shell_switcher.py`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switcher.py) queries `hyprctl activeworkspace -j` on launch and passes the workspace ID to `dusky_shell_switch.sh`.
2. **Headless Fallback**: [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh) captures `$2` or queries `hyprctl activeworkspace -j` before terminating any process.
3. **Lua Native Dispatcher**: Dispatches `hl.dsp.focus({ workspace = "N" })` directly into Hyprland's Lua engine.
4. **Multi-Stage Deferred Retention**: Emits immediate focus, followed by background asynchronous focus pulses at 150ms, 500ms, and 1000ms to guarantee the user remains locked onto their intended workspace throughout process teardown and initialization.

---

## 5. Dual-Binary Teardown (`qs` vs `quickshell` Process Isolation)

### The Dual-Binary Trap
Different Quickshell-based shells launch under different binary names:
- **Serpantinum**: Launches as `quickshell -p ~/.config/quickshell/shell.qml`.
- **iNiR**: Uses the `/usr/bin/qs` launcher script/binary: `qs -n -d -p ~/.config/quickshell/inir`.
- **Duskytunes**: Runs as background client `qs -p /usr/share/duskytunes/client`.

A standard `killall quickshell` or `pkill -f quickshell.*inir` completely misses `/usr/bin/qs` processes, resulting in duplicate shells running simultaneously.

### The Teardown Matrix in `dusky_shell_switch.sh`
```bash
kill_serpantinum_all() {
    pkill -9 -f "quickshell.*shell.qml" 2>/dev/null || true
    pkill -9 -f "qs.*shell.qml" 2>/dev/null || true
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
```
