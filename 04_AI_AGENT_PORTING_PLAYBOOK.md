# Master AI Agent Porting Playbook for Dusky Linux

This playbook is the primary operational prompt, architectural reference, and execution algorithm for AI coding agents tasked with porting any desktop shell (Quickshell, AGS, Eww, Waybar, etc.) onto Dusky Linux (Arch Linux + Hyprland Lua).

---

## The Golden Rules for AI Agents Porting to Dusky

> [!IMPORTANT]
> 1. **Dusky Strictly Owns App Theming**: Foreign shell color scripts (`apply-gtk-theme.sh`, `20-gtk-kde.sh`, `terminals.sh`, etc.) must be neutered (`exit 0`). Never let a foreign shell rewrite `gsettings`, `gtk-3.0/settings.ini`, `gtk-4.0/settings.ini`, `qt5ct.conf`, `qt6ct.conf`, or `xsettingsd.conf`.
> 2. **Never Use Symlinks to Staging Directories**: Always copy payloads physically into their permanent directories (`~/.config/quickshell/<shell_name>/` or `~/.config/quickshell/`). The user deletes cloned and public folders later.
> 3. **The Trap of `modules.background: false`**: Never unload background canvas modules if desktop right-click menus or desktop widgets live inside them. Instead, use a transparent pass-through (`showInternalStaticWallpaper = false` or `externalWallpaper = true`), allowing `skwd-wall-v2` to render the wallpaper while the shell captures right-clicks.
> 4. **Never Use Wildcard Layer Rules**: Never create a rule like `match = { namespace = "^quickshell.*" }` with `blur = true`. This blurs fullscreen background layers (blurring the wallpaper) and blurs screen capture selectors (freezing screenshot tools). Always separate interactive panels (blurred) from fullscreen backgrounds/selectors (`blur = false`).
> 5. **Unify Keybindings via Smart Dispatchers**: Never inject foreign keybindings into Hyprland. Bind all shortcuts to Dusky's shell-aware smart dispatchers (`smart_launcher.sh`, `smart_control_center.sh`, `smart_sidebar.sh`, `smart_lock.sh`, `smart_clipboard.sh`).
> 6. **Bidirectional Wallpaper Sync**: All wallpaper triggers inside the shell must route to `/usr/bin/skwd-wall-v2` or `~/user_scripts/hypr/sync_wallpaper.sh`. Changes made in `skwd-wall-v2` must propagate to the shell's config, and vice versa.
> 7. **Dynamic Matugen Colors**: Generate dynamic Material tokens using Matugen templates so every shell and subshell matches the wallpaper's colors automatically.
> 8. **Workspace Retention on Transitions**: In setups with `focus_on_close = 0`, closing layers or killing shells causes Hyprland to kick focus to Workspace 2. Switchers must capture `hyprctl activeworkspace -j` upfront and emit `hl.dsp.focus({ workspace = "N" })` (Hyprland 0.55+ Lua syntax) immediately and on deferred timers (150ms, 500ms, 1000ms).
> 9. **Dual-Binary Teardown (`qs` vs `quickshell`)**: Quickshell can run as `quickshell` or alias/binary `qs`. Always kill both command signatures (`qs.*<name>` and `quickshell.*<name>`) to prevent concurrent shells from running side-by-side.
> 10. **Toplevel Pointer Life-cycle Guard**: In Quickshell QML models iterating over toplevel windows, cross-reference against live `ToplevelManager.toplevels.values` and wrap identity lookups in `try { ... } catch (e)` to prevent Segfault 11 crashes when windows close.
> 11. **Pre-Flight Backup & Safe Rollback**: Always create a timestamped backup (`safe_config_merger.py --backup`) before editing user configs. If any syntax error or runtime crash occurs, immediately execute a safe rollback (`safe_config_merger.py --rollback`).
> 12. **Non-Destructive Merging**: Never overwrite or replace `keybinds.lua`, `window_rules.lua`, or `matugen/config.toml`. Users have existing custom bindings and application templates. Safely merge snippets without clobbering existing configuration.
> 13. **Consult Ubaid's Journey Docs When Stuck**: If an AI agent encounters unhandled behavior or crashes, it should not guess. It should consult the subshell archives in `serpantinum/` and `inir/`, which document Ubaid's real-world engineering journey, root-cause analyses, and solutions.

---

## Agent Protocol: 8-Phase Execution Algorithm

```
┌────────────────────────────────────────────────────────┐
│  Phase 1: Pre-Flight Inspection & Dependency Audit     │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 2: Filesystem Layout & Non-Colliding Isolation   │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 3: Theming Lockdown & Papirus-Dark Protection   │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 4: Transparent Wallpaper Pass-Through & Sync    │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 5: Notification Daemon Isolation (Mako Masking) │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 6: Smart Dispatchers & Dynamic Keybindings      │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 7: Precision Hyprland Layer Rules (Panel vs Bg) │
└───────────────────────────┬────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────┐
│  Phase 8: Universal Switcher Registration & Test Matrix│
└────────────────────────────────────────────────────────┘
```

---

## Phase 1: Pre-Flight Inspection & Dependency Audit

Before touching configuration files:
1. **Identify the shell runtime**:
   - Quickshell? (`quickshell -p <path>`)
   - AGS (Aylur's GTK Shell)? (`ags run -c <path>`)
   - Eww? (`eww -c <path>`)
   - Waybar?
2. **Audit required packages**:
   Check for critical system packages on Arch Linux:
   ```bash
   which quickshell hyprctl playerctl brightnessctl cava jq socat wireplumber grim slurp wl-copy 2>/dev/null
   ```
3. **Audit Qt6 and font dependencies** (for Quickshell ports):
   - `qt6-imageformats`, `qt6-multimedia-ffmpeg`, `qt6-declarative`, `qt6-svg`, `syntax-highlighting`, `wlsunset`
   - `ttf-roboto-flex`, `ttf-material-symbols-variable`, `ttf-font-awesome`, `ttf-jetbrains-mono-nerd`
   Install missing items:
   ```bash
   sudo pacman -S --needed qt6-imageformats qt6-multimedia-ffmpeg syntax-highlighting wlsunset
   yay -S --needed ttf-roboto-flex ttf-material-symbols-variable
   ```

---

## Phase 2: Filesystem Layout & Non-Colliding Isolation

Every shell must reside in an isolated location.

| Shell Architecture | Destination Path | Command to Launch |
| :--- | :--- | :--- |
| **Primary Quickshell Shell** | `~/.config/quickshell/` | `quickshell` (or `serpantinumd start`) |
| **Secondary Quickshell Shell** | `~/.config/quickshell/<name>/` | `quickshell -p ~/.config/quickshell/<name>` |
| **AGS Shell** | `~/.config/ags/<name>/` | `ags run -c ~/.config/ags/<name>` |
| **Eww Shell** | `~/.config/eww/<name>/` | `eww -c ~/.config/eww/<name>` |

### Rules:
- Physically copy all files: `cp -r <source> ~/.config/quickshell/<target>/`. Never leave symlinks to temporary folders.
- Ensure executable bits on all shell scripts and binaries:
  ```bash
  find ~/.config/quickshell/<target>/ -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
  ```

---

## Phase 3: Theming Lockdown & Papirus-Dark Protection

Many standalone shells (e.g. iNiR) attempt to act as complete OS theme managers by overwriting user configs on shell boot.

### The Lockdown Procedure:
1. Locate all color application scripts (e.g. `scripts/colors/apply-gtk-theme.sh`, `modules/*.sh`).
2. Replace each script with a safe no-op:
   ```bash
   printf '#!/usr/bin/env bash\nexit 0\n' > scripts/colors/apply-gtk-theme.sh
   chmod +x scripts/colors/apply-gtk-theme.sh
   ```
3. Ensure icon theme detection scripts return `Papirus-Dark`.
4. In the shell's config file (e.g. `config.json`), disable application and terminal theming:
   ```json
   {
     "wallpaperTheming": { "enableAppsAndShell": false },
     "theming": { "enableQtApps": false, "enableTerminal": false }
   }
   ```
5. If the shell has a Matugen or Material color loader (like `MaterialThemeLoader.qml`):
   - Create a template in `~/.config/matugen/templates/<shell>-colors.json`.
   - Register it in `~/.config/matugen/config.toml` targeting the shell's expected color state file.

---

## Phase 4: Transparent Wallpaper Pass-Through & Sync

Dusky uses `skwd-wall-v2` (front-end) and `skwd-wall-still` / `awww` (back-end).

### 4.1 The Transparent Pass-Through
- Do **NOT** set `"modules.background": false` if desktop right-click menus or widgets live inside the background module.
- Instead, render the background canvas as transparent:
  - In `Background.qml`: `showInternalStaticWallpaper: false`
  - In `IrisBackground.qml`: `externalWallpaper: true`
  - Ensure the root surface has `color: "transparent"`.

### 4.2 Redirecting Wallpaper Triggers
- Intercept context menu "Change wallpaper" and settings buttons to execute `/usr/bin/skwd-wall-v2`.

### 4.3 Bidirectional Synchronization
- Deploy `~/user_scripts/hypr/sync_wallpaper.sh` (from `bundle/scripts/sync_wallpaper.sh`).
- Hook the shell's internal wallpaper change script (`switchwall.sh`) to invoke `sync_wallpaper.sh "$image_path"`.
- When `sync_wallpaper.sh` runs, it updates `skwd-wall-still`, `skwd-wall-v2`, Dusky `dark_wal`, and triggers Matugen to generate colors for all shells.

---

## Phase 5: Notification Daemon Isolation (Mako Masking)

If the ported shell has its own notification service:
1. When entering the shell in `dusky_shell_switch.sh`:
   ```bash
   systemctl --user mask mako.service 2>/dev/null || true
   systemctl --user stop mako.service 2>/dev/null || true
   killall -9 mako 2>/dev/null || true
   ```
2. When switching back to Dusky Native:
   ```bash
   systemctl --user unmask mako.service 2>/dev/null || true
   systemctl --user start mako.service --no-block 2>/dev/null || true
   ```

---

## Phase 6: Smart Dispatchers & Dynamic Keybindings

Never rebind user shortcuts. Integrate the new shell into Dusky's existing smart dispatchers:

### 1. `smart_launcher.sh` (`Alt + Space`):
```bash
case "$ACTIVE_SHELL" in
    serpantinum) exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle launcher ;;
    inir*)       exec inir overview toggle ;;
    <new_shell>) exec <new_shell_launcher_cmd> ;;
    *)           pkill -x rofi 2>/dev/null || true; exec dusky-run rofi -show drun ;;
esac
```

### 2. `smart_control_center.sh` (`Super + Space`):
```bash
case "$ACTIVE_SHELL" in
    serpantinum) exec bash "$HOME/.config/quickshell/scripts/settings.sh" toggle ;;
    inir*)       exec inir controlPanel toggle ;;
    <new_shell>) exec <new_shell_cc_cmd> ;;
    *)           exec gdbus call --session --dest com.github.dusky.controlcenter ... ;;
esac
```

### 3. `smart_sidebar.sh` (`Super + Esc`):
```bash
case "$ACTIVE_SHELL" in
    serpantinum) exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle system ;;
    inir*)       exec inir sidebarRight toggle ;;
    <new_shell>) exec <new_shell_sidebar_cmd> ;;
    *)           exec hyprctl dispatch fullscreen 0 ;;
esac
```

### 4. `smart_lock.sh` (`Super + M`):
```bash
case "$ACTIVE_SHELL" in
    serpantinum) exec bash "$HOME/.config/quickshell/scripts/lock.sh" "$@" ;;
    inir*)       exec inir lock activate ;;
    <new_shell>) exec <new_shell_lock_cmd> ;;
    *)           exec hyprlock "$@" ;;
esac
```

### 5. `smart_clipboard.sh` (`Super + V`):
```bash
case "$ACTIVE_SHELL" in
    serpantinum) exec bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle clipboard ;;
    inir*)       exec inir clipboard toggle ;;
    <new_shell>) exec <new_shell_clipboard_cmd> ;;
    *)           exec foot --app-id=terminal_clipboard.sh "$HOME/user_scripts/clipboard/terminal_clipboard.sh" ;;
esac
```

---

## Phase 7: Precision Hyprland Layer Rules (Panel vs Background)

In `~/.config/hypr/edit_here/source/window_rules.lua`:

### 1. Interactive Panels (Blur Allowed)
```lua
hl.layer_rule({
    name = "<shell>_panels_blur",
    match = { namespace = "^<shell>:(bar|dock|drawer|popup|launcher|controlPanel|...)$" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})
```

### 2. Fullscreen Backgrounds & Capture Surfaces (Strictly NO BLUR)
```lua
hl.layer_rule({
    name = "<shell>_background_no_blur",
    match = { namespace = "^<shell>:(background|backdrop|regionSelector|annotationEditor|.*Backdrop|.*catcher|.*Scrim)$" },
    blur = false
})
```

---

## Phase 8: Universal Switcher Registration & Test Matrix

### 8.1 Register in `~/user_scripts/hypr/dusky_shell_switch.sh`
1. Define `kill_<new_shell>_all()`.
2. Define `apply_<new_shell>()`.
3. Add CLI arguments: `--<new_shell> | <new_shell>`.

### 8.2 Register in `~/user_scripts/hypr/dusky_shell_switcher.py`
Add the shell entry to the `SHELLS` dictionary with name, title, description, and preview image:
```python
{
    "id": "<new_shell>",
    "title": "My Shell",
    "desc": "Description of shell",
    "icon": "preferences-desktop-theme",
    "preview": os.path.expanduser("~/Public/dusky_shell_porting_guide/assets/screenshots/<new_shell>_desktop.png")
}
```

### 8.3 Verification Checklist
Run through the complete interactive test suite:
- [ ] Shell switcher GUI (`Super + Ctrl + S`) opens with clean styling.
- [ ] Switching between shells transitions cleanly without lingering processes (`ps aux | grep quickshell`).
- [ ] Desktop right-click opens the context menu.
- [ ] `Alt + Space` opens the active shell's app launcher.
- [ ] `Super + Space` opens the active shell's control center.
- [ ] `Super + Esc` toggles side drawer or exits fullscreen.
- [ ] `Super + M` locks the session; unlocking works cleanly.
- [ ] `Super + V` opens clipboard; pressing `ESC` exits immediately.
- [ ] Screenshot (`Print` or `Super + Shift + S`) works with crisp, non-blurred region selection and instant copy.
- [ ] Desktop wallpaper is crisp (not blurred or double-rendered).
- [ ] Changing wallpaper in `skwd-wall-v2` updates the shell's palette via Matugen.
- [ ] Changing wallpaper in the shell's settings updates `skwd-wall-still` and Dusky state.
- [ ] GTK3/GTK4 apps, Thunar, and icons retain `Papirus-Dark` and `dusky-matugen-b`.
