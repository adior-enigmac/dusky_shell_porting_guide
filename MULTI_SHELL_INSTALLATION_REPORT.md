# Multi-Shell Installation Report

- **Machine:** adior's Dusky Linux (CachyOS kernel), Hyprland 0.56.0 (Lua config), Matugen 4.2.0
- **Date:** 2026-10-30
- **Installed:** Serpantinum 2.3.0 (`ilyamiro/serpantinum`, commit a62f825) and iNiR 2.33.0 (`snowarch/iNiR`)
- **Overall status:** Installed and working, with three items still open (see the end of this report)

---

## 1. Safety & Backup Status

- **Backup directory:** `~/.config/dusky_multishell_backups/backup_20261030_004215/`
  - Created by `safe_config_merger.py --backup`. It holds 5 files: both `keybinds.lua`, both `window_rules.lua`, and `matugen/config.toml`.
  - It also holds an extra `full_snapshot.tar.gz` of `~/.config/hypr`, `~/.config/matugen`, `~/user_scripts/hypr` and `~/.config/quickshell`.
- **Rollback:** `python3 ~/user_scripts/hypr/safe_config_merger.py --rollback`
- **Merging:** no user file was overwritten. Every change was an append.
  - **`edit_here/source/keybinds.lua`:** six smart dispatchers were added.
    - I used `hl.unbind()` before each `hl.bind()`. The bundled snippet doesn't, so it would have double-bound `SUPER+SPACE`, `ALT+SPACE`, `SUPER+M` and `SUPER+V` on this machine.
    - I used this machine's `"SUPER + SPACE"` key format.
  - **`edit_here/source/window_rules.lua`:** the bundled layer-rule snippet was appended unchanged.
  - **`matugen/config.toml`:** only `serpantinum_quickshell` and `inir_quickshell` were appended. Both were dry-run against Matugen 4.2.0 first and produce valid JSON.
    - I skipped `serpantinum_wallpaper` and `shell_switcher`. Their input files (`current-wallpaper.txt`, `shell-switcher.css`) are not in the bundle, and a missing template input would break the whole Matugen run.
- **Validation:**
  - `luac -p` passes on both Lua files.
  - `tomllib` passes on `config.toml`.
  - `hyprctl reload` reports no config errors.
  - `hyprctl binds` shows all six bindings registered once each.

## 2. System & Package Verification

- **Already present:** quickshell/qs, hyprctl, matugen, cava, socat, jq, wpctl, brightnessctl, playerctl, grim, slurp, wl-copy, cliphist, foot, rofi, luac, yay, paru, skwd-wall-v2, skwd-wall-still, qt6-multimedia-ffmpeg, syntax-highlighting, qt6-svg, JetBrains Mono Nerd, python-websockets, python-jeepney, qt6-websockets.
- **Installed per user, no root needed:** Material Symbols Rounded and Outlined, from Google's `material-design-icons` repo, in `~/.local/share/fonts/MaterialSymbols/`. This fixed iNiR showing icon names as text.
- **Still missing (needs sudo):**
  - `qt6-imageformats`: Serpantinum can't decode `.webp` wallpapers without it.
  - `wlsunset`
  - `ttf-roboto-flex` (AUR), plus the Readex Pro and Space Grotesk fonts. Without them, text falls back to other fonts.

## 3. Repository Deployment

Both repositories were cloned and physically copied; nothing is symlinked to the staging area.

- **Serpantinum:** upstream now ships its payload under `src/`, and its main file is `quickshell/Shell.qml`, not a root `shell.qml`.
  - `src/*` was copied to `~/.config/quickshell/`, which gives `quickshell/`, `scripts/`, `assets/` and `version.txt`. The existing `panacea` symlink is untouched.
  - The binaries live in `~/.local/share/serpantinum/bin/`.
  - `~/.local/bin/serpantinum{,d}` are wrappers that export `SERPANTINUM_DIR=~/.config/quickshell`.
  - `~/.config/serpantinum/settings.json` was built from the upstream template, with the guide's toggles applied.
- **iNiR:**
  - The repo was copied to `~/.config/quickshell/inir/` without `.git`.
  - `~/.local/bin/inir` is the launcher the guide specifies.
  - `~/.config/inir/config.json` was built from upstream `defaults/config.json` with `panelFamily=iris`, `modules.background=true`, and app, Qt and terminal theming off.
- **Bundle scripts:** copied to `~/user_scripts/hypr/`. No existing file had the same name.

## 4. Applied Fixes Checklist

| Fix | Status | Notes |
|---|---|---|
| `qs` vs `quickshell` process isolation | Done, adapted | The Serpantinum kill pattern was changed to `(quickshell\|qs) .*\.config/quickshell/quickshell/Shell\.qml`. The guide's `quickshell.*shell.qml` doesn't match the capital-S `Shell.qml`. |
| Hyprland 0.55+ Lua workspace retention | Done | As bundled. |
| Serpantinum clipboard: screen fallback | Done | `ClipboardController` and `LauncherController` fall back to `Quickshell.screens[0]`. |
| Serpantinum clipboard: Escape dismiss | Already upstream | The search field already closes on Escape. The guide's `Keys` on a `PanelWindow` was skipped because it isn't a valid attachment there. |
| Serpantinum TopBar clipboard button | Done | Added in `bar/faces/left/LeftFace.qml`. |
| Serpantinum Control Center clipboard tile | Done | Added in `syspanel/SystemPanelQuickActions.qml`. |
| Serpantinum sidebar IPC toggle | Done, not bound | `FloatingController.toggle()`, IPC `floating toggle` and `Floating.onToggleRequested`. `smart_sidebar.sh` now points at `quickshell/Shell.qml`. It is **not** bound to `SUPER+ESC`, because adior uses that key to close windows. |
| iNiR theme script lockdown | Done | `scripts/colors/apply-gtk-theme.sh` and `scripts/colors/modules/20-gtk-kde.sh` now just `exit 0`. |
| iNiR toplevel lifecycle segfault fix | Done | Live-toplevel filter in `CompositorService.qml`, plus try/catch in `AppSearch.resolveWindowIdentity` and the `TaskbarApps` loop. |
| iNiR island lock button | Not needed | Upstream `Session.lock()` already calls `inir lock activate`, which is what `smart_lock.sh` uses. |
| iNiR wallpaper selector to skwd-wall-v2 | Not applied | `WallpaperSelectorRouter.qml` no longer exists upstream. |
| Transparent background with skwd-wall-v2 sync | Done, fixed | See below. |

### Additional fixes not in the guide

1. **iNiR launcher exited silently on Hyprland.**
   - **Cause:** in `scripts/inir`, `apply_niri_app_environment` ends with `[[ -n "$value" ]] && export ...`. When no niri config exists, that returns 1, and `set -euo pipefail` aborts `inir run`.
   - **Fix:** added `return 0`. This is worth reporting upstream.
2. **Serpantinum `wallpaper` setting.**
   - Upstream reads the top-level `wallpaper` as a path string (`ThemeBackend.qml:271`, `Config.getSetting("wallpaper", "")`).
   - The guide's `"wallpaper": {"enabled": false}` object breaks Matugen theming with `TypeError: Property 'trim' ... is not a function`.
   - It's now set to the wallpaper path. I also removed `.wallpaper.enabled = false` from the `jq` filter in `dusky_shell_switch.sh`, because it fails on a string and silently skips every other setting in that filter.
3. **`sync_wallpaper.sh` picked a stale wallpaper.**
   - It read Dusky's `dark_wal`, which pointed to an older image. It then overwrote skwd-wall-v2's `lastAppliedKey`. The displayed wallpaper never changed, and the key was restored.
   - The script now uses the image the running `skwd-wall-still` is displaying.
   - It only relaunches `skwd-wall-still` when the image actually changes.

## 5. Test Verification

| Test | Result |
|---|---|
| Switch to Serpantinum | Pass. One `quickshell -p .../quickshell/Shell.qml` process, plus the daemon and focus helper. |
| Serpantinum Control Center, Clipboard and Sidebar toggles | Pass. Exit 0, and no errors from the patched files in the Quickshell log. |
| Switch to iNiR iRiS | Pass after fix 1. One `qs -n -d -p ~/.config/quickshell/inir` process, and the iRiS island renders. |
| iNiR Control Center, Clipboard and Sidebar via smart dispatchers | Pass. Exit 0 on open and close. |
| iNiR Material ii | Not run. The user was using the desktop. |
| iNiR Waffle | Not run. The user was using the desktop. |
| Duplicate shell processes | None seen during these tests. |

**Remaining log warnings (upstream, not blocking):**
- iNiR `Workspaces.qml:546: biggestWindowForWorkspace is not a function`
- `Background.qml:554: Cannot call method 'filter' of undefined`
- Serpantinum webp decode warnings until `qt6-imageformats` is installed

## 6. Open Items

1. `sudo pacman -S --needed qt6-imageformats wlsunset` and `yay -S --needed ttf-roboto-flex`
2. Test the switches to Material ii and Waffle (`Super+Ctrl+S`).
3. Finish Serpantinum's first-launch welcome screen.
4. After a reboot the session starts in plain Dusky. Nothing autostarts the last-selected shell yet; `dusky_shell_switch.sh --autostart` exists but isn't wired into `autostart.lua`.

---

**Setup is complete apart from the open items above. Please share this report with Ubaid.**
