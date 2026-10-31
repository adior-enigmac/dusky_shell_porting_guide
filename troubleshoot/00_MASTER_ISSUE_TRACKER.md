# Master Issue Tracker & Resolution Index

This document provides a high-level inventory of all recorded defects, environmental quirks, and resolved regressions across the Dusky Linux Multi-Shell ecosystem.

Shell-specific troubleshooting guides and dedicated issue trackers are maintained directly within each respective shell's `troubleshooting/` folder:
- **Global / System-Wide Issues:** [01_GLOBAL_AND_SYSTEM_ISSUES.md](01_GLOBAL_AND_SYSTEM_ISSUES.md)
- **Serpantinum Shell Issues:** [Serpantinum Troubleshooting](../serpantinum/troubleshooting/README.md) | [Serpantinum Issue Tracker](../serpantinum/troubleshooting/00_SERPANTINUM_ISSUE_TRACKER.md)
- **iNiR Shell Issues:** [iNiR Troubleshooting](../inir/troubleshooting/README.md) | [iNiR Issue Tracker](../inir/troubleshooting/00_INIR_ISSUE_TRACKER.md)

---

## Issue Status Legend
* `[FIXED]`: Fully root-caused, patched in the codebase/scripts, and verified live.
* `[WORKAROUND]`: Documented workaround available while waiting for upstream resolution.
* `[INVESTIGATING]`: Under active diagnosis.

---

## Comprehensive Master Inventory

| ID | Scope | Component | Symptoms | Status | Resolution Summary | Document Reference |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **G-01** | Global | Lid Close / Sleep | Quickshell quits after laptop lid is closed for a long time | `[FIXED]` | Separated lid lock to `loginctl lock-session`, added `--ensure-running` to lid-open, added respawn loop to `serpantinumd` | [G-01 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-01-quickshell-quits-after-prolonged-laptop-lid-close) |
| **G-02** | Global | Hyprland Keybinds | Double execution or keybinding conflicts on `SUPER+SPACE`, `ALT+SPACE`, etc. | `[FIXED]` | Prepend `pcall(hl.unbind, ...)` before each `hl.bind` in templates and merger | [G-02 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-02-hyprland-keybinding-collisions--duplicate-binds) |
| **G-03** | Global | Matugen | Matugen fails with missing input template error on fresh installs | `[FIXED]` | Bundled `current-wallpaper.txt` and `shell-switcher.css` into `bundle/templates/` and auto-deploy in merger | [G-03 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-03-missing-matugen-input-templates) |
| **G-04** | Global | Wallpaper Sync | `sync_wallpaper.sh` picks stale wallpaper from static `dark_wal` | `[FIXED]` | Prioritize running `skwd-wall-still` and `awww` queries; add anti-flicker process guard | [G-04 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-04-sync_wallpapersh-reading-stale-wallpaper) |
| **G-05** | Global | Session Boot | System starts in plain Dusky after reboot; last-used shell not restored | `[FIXED]` | Add `dusky_shell_switch.sh --autostart` to `autostart.lua` | [G-05 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-05-shell-not-autostarting-after-reboot) |
| **G-06** | Global | Workspace Focus | Switching shells throws user to Workspace 2 | `[FIXED]` | Pre-capture workspace in GUI and emit multi-stage deferred `hl.dsp.focus` Lua commands | [G-06 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-06-workspace-switcher-drops-focus-to-workspace-2) |
| **G-07** | Global | Process Teardown | Concurrent shells running side-by-side (e.g. Waffle + Serpantinum) | `[FIXED]` | Dual-regex teardown matching both `/usr/bin/qs` and `quickshell` binary signatures | [G-07 Details](01_GLOBAL_AND_SYSTEM_ISSUES.md#g-07-ghost-shells-running-simultaneously-qs-vs-quickshell) |
| **S-01** | Serpantinum | Clipboard | Image previews are super short/collapsed (52px) by default | `[FIXED]` | Default `itemExpanded` to `true` for `model.type === "image"`; allocate `s(250)` in `targetLauncherHeight` | [S-01 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-01-clipboard-image-preview-collapsed-by-default) |
| **S-02** | Serpantinum | Settings / Matugen | `TypeError: Property 'trim' ... is not a function` breaks Matugen colors | `[FIXED]` | Store `wallpaper` as string path in `settings.json`, remove `.wallpaper.enabled = false` from jq filter | [S-02 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-02-settingsjson-wallpaper-object-breaks-matugen-theming) |
| **S-03** | Serpantinum | Process Management| Process kill fails on newer Serpantinum versions (`quickshell/Shell.qml`) | `[FIXED]` | Use case-insensitive pattern `[sS]hell\.qml` across all switcher and killer scripts | [S-03 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-03-upstream-entry-point-casing-shellqml-vs-shellqml) |
| **S-04** | Serpantinum | Clipboard | Clipboard window does not close on `Escape` key | `[FIXED]` | Added window-level `Keys.onEscapePressed` directly to root `PanelWindow` | [S-04 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-04-clipboard-window-escape-key-handling) |
| **S-05** | Serpantinum | Focus / Multi-Screen | Quickshell crashes or fails to toggle overlay when screen is null | `[FIXED]` | Added fallback to `Quickshell.screens[0]` in `ClipboardController` & `LauncherController` | [S-05 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-05-null-screen-fallback-in-overlay-controllers) |
| **S-06** | Serpantinum | Daemon Watchdog | Shell terminates and never resumes on display sleep/wake | `[FIXED]` | Added persistent supervisor loop in `serpantinumd` + `--ensure-running` watchdog | [S-06 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-06-serpantinum-daemon-watchdog--sleep-recovery) |
| **S-07** | Serpantinum | Updater / Guide | Update notification and About tab execute `install.sh` and destroy patches | `[FIXED]` | Neutered updater loop, silenced notifications, disabled update button with Dusky badge | [S-07 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-07-upstream-updater-overwrite-trap--permanent-neutralization) |
| **S-08** | Serpantinum | Upstream 2.3.1 | Qt binding loops, corner overlap & multi-bluetooth shader limits | `[FIXED]` | Cherry-picked GlassFill, BarModule, Floating, and 16-beam shader; bumped version to 2.3.1 | [S-08 Details](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md#s-08-upstream-231-safe-improvements-cherry-pick--synchronization) |
| **I-01** | iNiR | CLI Launcher | `inir run` exits silently with code 1 on Hyprland | `[FIXED]` | Added `return 0` to `apply_niri_app_environment()` in `scripts/inir` | [I-01 Details](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md#i-01-inir-cli-launcher-exits-silently-with-code-1-on-hyprland) |
| **I-02** | iNiR | Fonts / Glyphs | Icon names displayed as raw plain text instead of glyphs | `[FIXED]` | Deployed Material Symbols Rounded & Outlined to `~/.local/share/fonts/MaterialSymbols/` | [I-02 Details](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md#i-02-missing-material-symbols-fonts-render-icons-as-raw-text) |
| **I-03** | iNiR | Compositor Service| Quickshell crashes with Segfault 11 (`QQmlMetaType::propertyCache`) on window close | `[FIXED]` | Filter `ordered.map(x => x.wayland)` against live `ToplevelManager` set; wrap lookups in try/catch | [I-03 Details](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md#i-03-toplevel-lifecycle-segfault-11-on-window-close) |
| **I-04** | iNiR | Session Lock | Island popup lock button does not activate screen lock | `[FIXED]` | Route `Session.lock()` through `smart_lock.sh` or trigger `inir lock activate` | [I-04 Details](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md#i-04-island-popup-lock-button-inoperative) |
| **I-05** | iNiR | Theme Lockdown | External scripts overwrite Dusky GTK/KDE palettes | `[FIXED]` | Prepend `exit 0` to `apply-gtk-theme.sh` & `20-gtk-kde.sh` | [I-05 Details](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md#i-05-theme-script-lockdown-preventing-gtk-kde-overwrites) |
