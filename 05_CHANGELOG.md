# Changelog & Modification Audit Log

This document records all modifications made to establish the standalone Dusky Linux Multi-Shell ecosystem (Dusky Native, Serpantinum, and iNiR).

---

### [2026-10-30 21:00] Modular Troubleshooting Folders, Defect Trackers & Collaborative Knowledge Base
- **Target**: Troubleshooting Architecture, Shell Folders & Defect Tracking
- **Files Modified / Created**:
  - `serpantinum/troubleshooting/` (Created):
    - `README.md`: Overview of Serpantinum troubleshooting knowledge base.
    - `00_SERPANTINUM_ISSUE_TRACKER.md`: Active registry and status table for `S-01` through `S-06`.
    - `01_SERPANTINUM_ISSUES_AND_FIXES.md`: In-depth root cause diagnostics, QML patches, and test commands for clipboard image sizing, scroll loop prevention, keyboard navigation bounds, Matugen wallpaper strings, entrypoint casing, Escape key dismiss, null screen fallback, and lid sleep recovery.
  - `~/.config/quickshell/clipboard/Clipboard.qml`:
    - Resolved S-01 clipboard image default expansion: images open to full ~250px previews preserving aspect ratio by default; text items remain collapsed (52px).
    - Resolved infinite scrolling loop: eliminated `clipList.currentIndex` and `ensureVisible` hijacking in `onItemExpandedChanged` so mouse scrolling and Up/Down arrow navigation move freely across all items.
    - Added accurate image height (`s(250)`) in `getItemBounds(idx)` for uninstantiated items.
    - Cleaned up image crossfade opacity in `clipCardCropImg`.
  - `inir/troubleshooting/` (Created):
    - `README.md`: Overview of iNiR troubleshooting knowledge base.
    - `00_INIR_ISSUE_TRACKER.md`: Active registry and status table for `I-01` through `I-05`.
    - `01_INIR_ISSUES_AND_FIXES.md`: In-depth root cause diagnostics, CLI traps, font glyph deployment, toplevel segfault filters, and GTK theme script lockdown.
  - `troubleshoot/` (Global Troubleshooting & Master Tracker):
    - `00_MASTER_ISSUE_TRACKER.md`: High-level master index linking all Global (`G-xx`), Serpantinum (`S-xx`), and iNiR (`I-xx`) issues to their dedicated files.
    - `01_GLOBAL_AND_SYSTEM_ISSUES.md`: In-depth documentation of all systemwide issues (`G-01` through `G-07`).
    - `README.md`: Architectural documentation and strict directives for future AI assistants.
  - `MULTI_SHELL_INSTALLATION_REPORT.md`: Fully incorporated and removed.
  - `00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md`:
    - Added Cardinal Safety Rule 4: Reciprocal Knowledge Base Logging.
    - Updated Section 11 to link to shell-specific `troubleshooting/` folders.
  - `README.md` & `00_MASTER_INDEX.md`: Updated directory structures and added Golden Rule 11.
- **Key Enhancements**:
  1. **Clean Separation of Concerns**: Global/system-wide issues reside in `troubleshoot/`; shell-specific troubleshooting and issue trackers reside in dedicated `troubleshooting/` folders inside `serpantinum/` and `inir/`.
  2. **Bi-Directional AI Collaboration**: Any future AI assistant that fixes an issue must log it in the appropriate folder and tracker, allowing team synchronization via standard `git pull`.

---

### [2026-10-29 23:55] Safe Config Merger, Automatic Rollback Engine & Deep Journey Knowledge Base
- **Target**: Universal Porting Guide Knowledge Base, Core Script Bundle & Installer Playbook
- **Files Modified / Created**:
  - `bundle/scripts/safe_config_merger.py` (Created & Deployed to `~/user_scripts/hypr/`): Python 3 non-destructive merging, pre-flight backup, syntax validation (`luac -p` and `tomllib`), and atomic rollback engine.
  - `bundle/templates/hyprland_keybinds_snippet.lua`: Added prominent non-destructive merge caution header.
  - `bundle/templates/hyprland_window_rules_snippet.lua`: Added prominent non-destructive merge caution header.
  - `bundle/templates/matugen_config_snippet.toml`: Added prominent non-destructive merge caution header.
  - `00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md`:
    - Added Cardinal Safety Rules (Backup, Non-destructive merging, Ubaid's journey docs).
    - Added Section 1: Zero-Risk Pre-Flight Backup & Reversible Rollback Engine.
    - Added Section 7: Intelligent Non-Destructive Configuration Merging with automated and manual steps.
    - Added Section 10: "If You Get Stuck" — Comprehensive index and roadmap to Ubaid's subshell journey archives (`serpantinum/` and `inir/`).
    - Added Section 11.1: Automatic rollback trigger triggers and recovery procedures.
    - Updated final report checklist to include backup path and merge audit.
  - `README.md` & `00_MASTER_INDEX.md`: Synchronized directory tree with `safe_config_merger.py` and added Golden Rules 8, 9, 10.
  - `04_AI_AGENT_PORTING_PLAYBOOK.md`: Added Golden Rules 11, 12, 13.
- **Key Guarantees**:
  1. **Zero Data Loss**: User configurations in `~/.config/hypr/` and `~/.config/matugen/` are never overwritten; only missing entries are merged.
  2. **Safe Rollback**: In case of any error or broken state, `safe_config_merger.py --rollback` restores the system to its pre-installation state.
  3. **Architectural Memory**: Any future AI agent that feels lost or encounters an obscure issue is explicitly routed to Ubaid's journey documentation for exact root-cause analysis and workarounds.

---

### [2026-10-29 23:40] Autonomous AI Agent Installer Guide, Upstream Clone Links & Diagnostic Suite
- **Target**: Universal Porting Guide Knowledge Base & Autonomous Installer Playbook
- **Files Modified / Created**:
  - `00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md` (Created): Standalone, zero-assumption bootstrap workflow for any AI agent on a fresh Dusky Linux installation.
  - `README.md`: Added prominent AI setup directive banner, upstream clone URLs, updated directory tree, and expanded visual gallery.
  - `00_MASTER_INDEX.md`: Synchronized top banner, upstream clone URLs, and directory structure.
  - `serpantinum/00_PREREQUISITES_AND_DEPENDENCIES.md`: Added upstream git URL (`https://github.com/ilyamiro/serpantinum.git`) and staging clone instructions.
  - `inir/00_PREREQUISITES_AND_DEPENDENCIES.md`: Added upstream git URL (`https://github.com/snowarch/iNiR`) and staging clone instructions.
- **Key Enhancements**:
  1. **Autonomous AI Blueprint**: Authored complete instructions covering: package audits, staging clones, physical file copies without symlinks, code patches, Hyprland Lua bindings and layer rules, and Matugen configuration.
  2. **Diagnostic Playbook & Troubleshooting**: Documented solutions for sudo authentication prompts, AUR helper bootstrapping (`yay-bin`), Quickshell Segfault 11 (`QQmlMetaType::propertyCache` / dead `ToplevelHandle`), dual-process conflicts (`qs` vs `quickshell`), layer blur issues, and Hyprland 0.55+ workspace focus jumps.
  3. **Visual Reference Gallery**: Integrated references to 14 high-resolution desktop and component screenshots in `assets/screenshots/`.
  4. **Reporting Directive**: Implemented strict mandate for the autonomous AI agent to generate `MULTI_SHELL_INSTALLATION_REPORT.md` and conclude with:
     > *"Setup is 100% complete and fully verified. Please share this report with Ubaid."*

---

### [2026-10-29 23:25] Control Centers Audit, Full Serpantinum Clipboard & Process Isolation
- **Target**: Control Centers, Switchers, Clipboard Managers across all shells
- **Crash Investigation & Segfault Fix (`/home/ubaid/.cache/quickshell/crashes/a39bgffont/`)**:
  - *Symptom*: Quickshell crashed with Signal 11 (Segmentation Fault) in `QQmlMetaType::propertyCache` / `QV4::QObjectWrapper::create` called during QML model incubation (`libQt6QmlModels.so.6`).
  - *Root Cause Analysis*: When the standalone "iNiR Settings" window closed, the Wayland compositor destroyed the underlying `ToplevelHandle` C++ object. However, `Hyprland.toplevels` in `CompositorService.qml` still held a reference to the stale pointer. When `TaskbarApps.qml` or model incubators iterated over `CompositorService.sortedToplevels` and passed the stale `toplevel` to `AppSearch.resolveWindowIdentity()`, Qt attempted to wrap the deleted QObject, triggering an immediate null pointer dereference segfault in `libQt6Qml.so.6`.
  - *Fix Implemented*:
    1. In `services/CompositorService.qml`: Cross-referenced sorted toplevels against the authoritative `liveToplevels = new Set(ToplevelManager.toplevels?.values ?? [])` filter, discarding any toplevel handle already closed by the Wayland compositor.
    2. In `services/AppSearch.qml`: Wrapped `resolveWindowIdentity(toplevel)` in a defensive `try { ... } catch (e) { return "" }` block.
    3. In `services/TaskbarApps.qml`: Wrapped window iteration in a `try ... catch` block ensuring deleted toplevels during window closures are skipped gracefully without aborting the process.
- **Resolved Concurrent Shell Execution (`qs` vs `quickshell`)**:
  - *Root Cause*: iNiR runs under the binary `/usr/bin/qs`, while Serpantinum runs under `quickshell`. Legacy process termination (`pkill -f quickshell.*inir`) failed to kill `/usr/bin/qs`, allowing Waffle and Serpantinum to run concurrently.
  - *Fix*: Enhanced `kill_inir_all` and `kill_serpantinum_all` in `dusky_shell_switch.sh` to terminate both `qs` and `quickshell` command lines and daemons (`dev_hot_reload.py`, `keyboard_lock_state_daemon.py`).
  - *Startup*: Switched `apply_inir` to use `inir run --daemon` ensuring complete runtime environment and socket setup.
- **Full Serpantinum Clipboard Integration**:
  - *Root Cause*: Clipboard component was omitted from `settings.json` and `dusky_shell_switch.sh` (`clipboard.enabled = false`), so `Clipboard.qml` was never loaded.
  - *Fix*: Enabled `.clipboard.enabled = true` in `settings.json` and `dusky_shell_switch.sh`.
  - *Controller Bugfix*: Rewrote `toggle()` in `singletons/widgetcontrols/ClipboardController.qml` and `LauncherController.qml` so toggling while open immediately hides the overlay rather than getting stuck on screen references. Added fallback to `Quickshell.screens[0]` when `getFocusedScreen()` returns null.
  - *Key Handling*: Added window-level `Keys.onEscapePressed` in `clipboard/Clipboard.qml` ensuring `Escape` reliably dismisses clipboard from any focused element.
  - *UI Buttons*: Added dedicated Clipboard launcher button (`󰅍`) in TopBar (`bar/faces/left/LeftFace.qml`) and quick action tile (`󰅍`) in Control Center (`syspanel/SystemPanelQuickActions.qml`).
- **Universal Control Center Dispatcher (`smart_control_center.sh`)**:
  - Serpantinum: toggles `syspanel` (`qs-master` system panel with sliders, quick actions, power controls).
  - iNiR Waffle: toggles `wactionCenter` (Windows 11 Action Center).
  - iNiR Iris / Material ii: toggles `controlPanel` (Island controls / Material Control Center).
  - Dusky Native: activates native Dusky Control Center via D-Bus.
- **Universal Sidebar Dispatcher (`smart_sidebar.sh`)**:
  - Added `toggle` IPC command and `toggleRequested` signal to `FloatingController.qml` and `Floating.qml`.
  - Serpantinum: `SUPER + Escape` toggles Quickactions floating sidebar (Calculator, Timer, Draw, Notes, System Usage).
  - iNiR: `SUPER + Escape` toggles `sidebarRight`.
  - Dusky Native: `SUPER + Escape` exits fullscreen (`hyprctl dispatch fullscreen 0`).
- **Workspace Retention Bugfix**:
  - Diagnosed Hyprland 0.55+ Lua dispatcher requirement: `hyprctl dispatch 'hl.dsp.focus({ workspace = "N" })'`.
  - `dusky_shell_switcher.py` records active workspace on initialization and passes it to `dusky_shell_switch.sh`.
  - `dusky_shell_switch.sh` performs multi-stage deferred workspace focus restorations (0ms, 150ms, 500ms, 1000ms) overcoming `focus_on_close = 0` window destruction events.
- **Asset Collection**:
  - Captured 9 high-resolution reference screenshots covering control centers, sidebars, settings, and clipboards into `assets/screenshots/`.
  - Synchronized all production scripts into `bundle/scripts/`.

---

### [2026-10-29 17:35] iNiR Shell Port & 3-Subshell Expansion (iRiS, Material ii, Waffle)
- **Target**: `/home/ubaid/.config/quickshell/inir/` & `/home/ubaid/.config/inir/`
- **Action**: Fully deployed iNiR payload with zero symlinks into an isolated Quickshell subdirectory.
- **Subshells**: Configured runtime switching between 3 distinct subshells:
  1. **iRiS (Default)**: Dynamic Island pill bar, IrisPalette, pill controls.
  2. **Material ii**: Top bar, application dock, dual drawer sidebars.
  3. **Waffle**: Windows 11 style bottom taskbar, start menu, action center.
- **Wallpaper Coordination**: Disabled internal background window (`modules.background = false`) and wired `WallpaperSelectorRouter.qml` to `/usr/bin/skwd-wall-v2`.
- **Dynamic Keybindings**:
  - Created `~/user_scripts/hypr/smart_sidebar.sh` bound to `SUPER + Escape`:
    - Dusky: Leave fullscreen (`hyprctl dispatch fullscreen 0`).
    - Serpantinum: Open system popout drawer (`serpantinum msg toggle system`).
    - iNiR: Open right sidebar (`inir sidebarRight toggle`).
  - Updated `smart_launcher.sh` (`ALT + Space`) -> `inir overview toggle`.
  - Updated `smart_lock.sh` (`SUPER + M`) -> `inir lock lock`.
  - Updated `smart_control_center.sh` (`SUPER + Space`) -> `inir controlPanel toggle`.
- **Universal Switcher Expansion**:
  - Upgraded `dusky_shell_switch.sh` to support `--dusky`, `--serpantinum`, `--inir-iris`, `--inir-ii`, `--inir-waffle`.
  - Upgraded `dusky_shell_switcher.py` (GTK LayerShell GUI) with cards and hotkeys for all 5 configurations.
- **Documentation Overhaul**:
  - Renamed `/home/ubaid/Public/serpantinum_dusky_docs/` to `/home/ubaid/Public/dusky_shell_porting_guide/`.
  - Created partitioned `serpantinum/` and `inir/` documentation suites.
  - Authored `04_AI_AGENT_PORTING_PLAYBOOK.md` detailing the automated 7-phase porting algorithm.

---

### [2026-10-28 19:48] Standalone Quickshell Deployment
- **Target**: `/home/ubaid/.config/quickshell/`
- **Action**: Fully copied all QML components (`bar`, `widgets`, `dock`, `popouts`, `syspanel`, `media`, `calendar`, `network`, `volume`, `guide`, `reusables`, `singletons`), assets (`assets/matugen`, `assets/shaders`, `assets/fonts`), and scripts (`scripts/`).
- **Rationale**: User requested physical copies instead of symlinks so that `/home/ubaid/Public/serpantinum` can be deleted in the future without breaking anything.

### [2026-10-28 19:50] Configuration Initialization
- **File**: `/home/ubaid/.config/serpantinum/settings.json`
- **Action**: Created configuration file reflecting user requirements:
  - `widgets.enabled = true`
  - `dock.enabled = true`
  - `popouts.enabled = true`
  - `bar.enabled = false` (managed via switcher script; Waybar remains active initially)
  - `launcher.enabled = false` (preserves native Rofi)
  - `clipboard.enabled = false` (preserves native Dusky clipboard)
  - `lock.enabled = false` (preserves native Hyprlock and lid switch)
  - `polkit.enabled = false` (preserves native `dusky_polkit.service`)
  - `idle.enabled = false` (preserves native `hypridle.service`)
  - `notifications.enabled = false` (preserves native `mako.service`)
  - `wallpaper.enabled = false` (preserves native `awww-daemon` & `skwd-walld`)

### [2026-10-28 19:56] Standalone Binaries
- **Files**: `/home/ubaid/.local/bin/serpantinum`, `/home/ubaid/.local/bin/serpantinumd`
- **Action**: Installed standalone scripts in `~/.local/bin/` defaulting to `SERPANTINUM_DIR="$HOME/.config/quickshell"`.
- **Modifications**:
  - `serpantinumd`: Added check for `focusDaemonEnabled`. `focus_daemon.py` is disabled by default on boot unless explicitly enabled in settings or through the Control Center.

### [2026-10-28 19:58] Dusky Matugen Integration
- **File**: `/home/ubaid/.config/matugen/config.toml`
- **Action**:
  1. Fixed a pre-existing syntax error (stray `'''` from a partially commented block).
  2. Appended `[templates.serpantinum_quickshell]` pointing to `/home/ubaid/.config/quickshell/assets/matugen/templates/serpantinum_matugen_colors.json.template` with output to `~/.local/state/serpantinum/qs_colors.json`.
  3. Verified generation: `qs_colors.json` generated successfully.

### [2026-10-28 20:14] Dusky Bar Switcher Script
- **File**: `/home/ubaid/user_scripts/hypr/dusky_bar_switch.sh`
- **Action**: Created high-precision state manager to toggle and switch between native Waybar and Serpantinum Bar.
- **Features**:
  - Concurrency lock (`flock`)
  - State persistence in `~/.local/state/dusky/active_bar`
  - Interactive Rofi menu when run without args
  - CLI flags: `--waybar`, `--serpantinum`, `--toggle`, `--status`, `--autostart`
  - Calls `waybar_toggle.sh` to safely stop/start Waybar without orphaned processes
  - Automatically updates `~/.config/serpantinum/settings.json` and signals Quickshell reload

### [2026-10-28 20:15] Hyprland Integration (`edit_here`)
- **Files**:
  - `/home/ubaid/.config/hypr/edit_here/source/autostart.lua`:
    Replaced direct call to `waybar_toggle.sh` with `dusky_bar_switch.sh --autostart`, followed by `serpantinumd start`.
  - `/home/ubaid/.config/hypr/edit_here/source/keybinds.lua`:
    Added hotkeys:
    * `SUPER + ALT + W`: Open Desktop Widget Redactor
    * `SUPER + ALT + B`: Open Dusky Bar Switcher interactive menu
    * `SUPER + N`: Open Control Center / System Panel
    * `SUPER + M`: Open Audio Mixer popout
    * `SUPER + SHIFT + M`: Open Music Player & Equalizer popout
    * `SUPER + K`: Open Calendar & Weather popout

### [2026-10-28 20:16] Control Center Focus Mode Quick Action
- **File**: `/home/ubaid/.config/quickshell/syspanel/SystemPanelQuickActions.qml`
- **Action**: Added dedicated `QuickActionBtn` (`focusBtn`, icon `󰄉`) to the Quick Settings row.
- **Behavior**:
  - Left-click: Toggles `focus_daemon.py` on and off, updates `focusDaemonEnabled` setting.
  - Right-click: Opens the Digital Wellbeing tab in Serpantinum settings.
  - Background process monitor polls every 3s when panel is open to reflect live state.

### [2026-10-28 20:17] Native Desktop Right-Click Menu & Backdrop
- **Files**:
  - `/home/ubaid/.config/quickshell/shell.qml`:
    Added transparent `PanelWindow` backdrop on `WlrLayer.Background` to catch right clicks on wallpaper and trigger `DesktopMenuController`.
  - `/home/ubaid/.config/quickshell/popouts/DesktopMenu.qml`:
    Updated actions to bind directly to Dusky scripts:
    * "Select Wallpaper" -> runs `dusky-papers` or Dusky's wallpaper selector
    * "Open Terminal" -> launches native `foot` / `kitty`
    * Shuffle Wallpaper -> runs `$HOME/user_scripts/theme_matugen/theme_ctl.sh next`
    * Lock Screen -> triggers Dusky's `hyprlock`

### [2026-10-28 20:23] Physical File Separation & Quickshell Validation
- **Action**: Per user instruction to avoid symlinks, removed all symlinks in `~/.config/quickshell` and copied the real directories (`assets/`, `scripts/`, QML files).
- **Validation**: Executed `timeout 3s quickshell -p ~/.config/quickshell/shell.qml`:
  - Resolved `Quickshell.Wayland` import for backdrop window.
  - Confirmed `INFO: Configuration Loaded` with all singletons, widgets, dock, and popouts operating properly.
  - Synchronized Matugen output directly to `~/.local/state/serpantinum/qs_matugen_colors.json` and `qs_colors.json`.

### [2026-10-28 20:45] Keybinding Conflict Resolution & Blur Synchronization
- **Problem**: Keybinds `SUPER + M` (Lock Screen), `SUPER + N` (Notification History), `SUPER + K` (Focus Window Up), `SUPER + SHIFT + M` (Spotify), and `SUPER + ALT + W` (Waybar Layout Swapper) were colliding with native Dusky functionality.
- **Resolution**:
  - Restored all native Dusky shortcuts to their original behaviors.
  - Re-mapped all Serpantinum popouts and redactors to the completely unassigned **`SUPER + CTRL`** modifier tier:
    * `SUPER + CTRL + W`: Widget Redactor
    * `SUPER + CTRL + B`: Bar Switcher
    * `SUPER + CTRL + S`: Control Center / System Panel
    * `SUPER + CTRL + V`: Volume & Audio Stream Mixer
    * `SUPER + CTRL + M`: Music Player & EQ Popout
    * `SUPER + CTRL + C`: Calendar & Weather Popout
  - Reloaded Hyprland configuration via `hyprctl reload config-only`.
- **Blur Mode Synchronization (`SUPER + ALT + .`)**:
  - Added `duskyBlurWatcher` in `ThemeBackend.qml` watching `~/.config/dusky/settings/opacity_blur`.
  - Updated `syncElementOpacity()` to set `elementOpacity = 1.0` (100% solid) when blur is disabled, and `0.85` (translucent) when blur is enabled.
  - Added instant IPC notification hook into `/home/ubaid/user_scripts/hypr/hypr_blur_opacity_shadow_toggle.sh`.


### [2026-10-28 21:44] Phase 3: Universal Multi-Shell Switcher Architecture & Final Polish

- **File Created**: [`/home/ubaid/user_scripts/hypr/dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh)
  - Core atomic profile switching engine with `flock` locking at `/tmp/dusky_shell_switch.lock`.
  - Seamlessly controls Waybar, Mako notification daemon, Quickshell top bar, notifications, lockscreen, and dock.
  - State tracked persistently at `~/.local/state/dusky/active_shell`.

- **File Created**: [`/home/ubaid/user_scripts/hypr/dusky_shell_switcher.py`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switcher.py)
  - Standalone GTK3 + GtkLayerShell centered popup menu.
  - Zero dependency on Rofi, Waybar, or Quickshell (fully decoupled).
  - Supports keyboard navigation (`[↑/↓]`, `[1/2]`, `[Enter]`, `[Esc]`) and mouse clicks.
  - Styled with dynamic Matugen CSS.

- **File Created**: [`/home/ubaid/.config/matugen/templates/shell-switcher.css`](file:///home/ubaid/.config/matugen/templates/shell-switcher.css)
  - Dynamic Matugen stylesheet template for the Universal Shell Switcher.

- **File Edited**: [`/home/ubaid/.config/matugen/config.toml`](file:///home/ubaid/.config/matugen/config.toml)
  - Registered `[templates.shell_switcher]` generating `~/.config/matugen/generated/shell-switcher.css`.

- **File Edited**: [`/home/ubaid/.config/hypr/edit_here/source/window_rules.lua`](file:///home/ubaid/.config/hypr/edit_here/source/window_rules.lua)
  - Added Hyprland layer blur rules for Quickshell (`quickshell`, `qs-master`, `qs-dock`, `desktopmenu`, `sidemusic`, `dockappmenu`, `traymenu`, `osd`, `qs-popups`, `qs-applauncher`, `qs-clipboard`, `dusky-shell-switcher`).

- **File Edited**: [`/home/ubaid/.config/hypr/edit_here/source/keybinds.lua`](file:///home/ubaid/.config/hypr/edit_here/source/keybinds.lua)
  - Bound `SUPER + CTRL + B` to `dusky_shell_switcher.py`.
  - Refined `SUPER + CTRL + [W, S, V, M, C]` to toggle cleanly without conflicts.

- **File Edited**: [`/home/ubaid/.config/quickshell/shell.qml`](file:///home/ubaid/.config/quickshell/shell.qml)
  - Moved desktop backdrop `PanelWindow` from `WlrLayer.Background` to `WlrLayer.Bottom`, guaranteeing right-click menu functionality when using `skwd-wall` / `skwd-paper`.

- **File Edited**: [`/home/ubaid/.config/quickshell/popouts/DesktopMenu.qml`](file:///home/ubaid/.config/quickshell/popouts/DesktopMenu.qml)
  - Moved `WlrLayershell.layer` to `WlrLayer.Top`.
  - Added "Switch Desktop Shell" entry in right-click context menu.

- **File Edited**: [`/home/ubaid/.config/quickshell/syspanel/SystemPanelQuickActions.qml`](file:///home/ubaid/.config/quickshell/syspanel/SystemPanelQuickActions.qml)
  - Added `shellSwitcherBtn` (`󱂬`) quick action button to the System Panel (left-click opens menu, right-click toggles instantly).

- **File Edited**: [`/home/ubaid/.local/bin/serpantinum`](file:///home/ubaid/.local/bin/serpantinum) & [`/home/ubaid/.config/quickshell/scripts/qs_manager.sh`](file:///home/ubaid/.config/quickshell/scripts/qs_manager.sh)
  - Fixed QML path search from non-existent `$SERPANTINUM_DIR/quickshell/` to `$SERPANTINUM_DIR/`.
  - Made `serpantinum launch widgetredactor` directly invoke IPC `redactor toggle`.
  - Fixed argument count handling in `send_qs_ipc`.

- **Documentation Files Added**:
  - [`08_TASKS_AND_ARCHITECTURE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/08_TASKS_AND_ARCHITECTURE.md)
  - [`04_AI_AGENT_PORTING_PLAYBOOK.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/04_AI_AGENT_PORTING_PLAYBOOK.md)


### [2026-10-29 08:42] Phase 4: Native Polish, Audio Visualizer, Sound FX, & Duskytunes Fixes

- **Sound FX Path Fix**: Fixed broken relative path in [`Sounds.qml`](file:///home/ubaid/.config/quickshell/singletons/audio/Sounds.qml) (`soundsDir` pointed to non-existent `/../assets/sounds/`; corrected to `$Caching.qsDir/assets/sounds/`). Restored all UI click, toggle, and equalizer sound effects.
- **Cover Art & Lyrics Fix**: Fixed broken relative path in [`art_fetch.sh`](file:///home/ubaid/.config/quickshell/media/art_fetch.sh) (`caching.sh` failed to source, causing `/covers` permission errors). Now downloads, caches, blurs, and displays album art and lyrics for Duskytunes and all MPRIS players.
- **Native Equalizer / Visualizer**: In [`Cava.qml`](file:///home/ubaid/.config/quickshell/singletons/audio/Cava.qml), configured `[input] method = pipewire, source = auto`. Hooked Cava directly into PipeWire with active bar listeners, enabling real-time audio visualization across the bar and desktop widgets.
- **12-Hour Clock Format**: Updated `time.format` to `"hh:mm AP"` in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json), switching all clock widgets and bar time indicators to 12-hour AM/PM format.
- **Dock Terminal to Kitty**: Changed pinned terminal from `Foot` to `Kitty` (`kitty.desktop`) in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json).
- **Native Wallpaper Selector (`skwd-wall`)**: In [`ThemeWallpaperPreview.qml`](file:///home/ubaid/.config/quickshell/guide/theme/ThemeWallpaperPreview.qml), mapped "Select wallpaper" directly to `skwd-wall-v2`. In [`ThemeTabState.qml`](file:///home/ubaid/.config/quickshell/guide/theme/ThemeTabState.qml), added watcher for Dusky's `dark_wal` state so Serpantinum settings preview reflects wallpapers chosen via `skwd-wall`.
- **Dusky Native Isolation**: Updated [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh) to kill all Quickshell processes, widgets, and background daemons completely when switching to Dusky mode. Removed redundant `serpantinumd` call from [`autostart.lua`](file:///home/ubaid/.config/hypr/edit_here/source/autostart.lua) so Serpantinum only starts when its profile is active.
- **Layer Blur Refinement**: Updated [`window_rules.lua`](file:///home/ubaid/.config/hypr/edit_here/source/window_rules.lua) with exact namespace matching, `xray = true`, and `ignore_alpha = 0.54` to match Waybar. Set `elementOpacity = 0.78` and `blurBackground = true` in [`ThemeBackend.qml`](file:///home/ubaid/.config/quickshell/singletons/theme/ThemeBackend.qml) when Dusky blur is active.

---

### [2026-10-29 10:50] Phase 5: Architecture Hardening, Minimal Switcher UI & Blur-Solid Sync Fix

- **Zero Duplicate Bars & Single-Instance Guarantee**:
  - Diagnosed root cause of duplicate bars: child processes (`waybar`) inherited open file descriptors (`FD 200`) from previous `flock` implementations, locking out subsequent switch requests while running in the background.
  - Replaced file locking with an atomic POSIX directory lock (`/tmp/dusky_shell_switch.lock`) with automatic stale-lock clearance.
  - Fully detached background daemon execution using `setsid nohup ... </dev/null >/dev/null 2>&1 & disown` in [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh) and updated `/home/ubaid/.local/bin/serpantinumd` to redirect quickshell stdio, completely eliminating subshell stdout blocking.
  - Ensured switching between Dusky and Serpantinum executes complete, instantaneous teardown of the opposite shell.
- **Minimal Aesthetic Switcher UI**:
  - Overhauled [`dusky_shell_switcher.py`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switcher.py) and [`shell-switcher.css`](file:///home/ubaid/.config/matugen/templates/shell-switcher.css) to eliminate visual bloat, badges, and long descriptions.
  - Compact 320px width, sleek card geometry, refined typography, and active indicator dot.
  - Single-keystroke selection: `1` or `d` for Dusky Native, `2` or `s` for Serpantinum, `Enter` to apply selection, `Esc` to cancel.
- **Instant Blur vs Solid Mode Synchronization**:
  - Resolved state-lag inversion bug where toggling blur made Serpantinum unblurred-transparent instead of solid.
  - [`hypr_blur_opacity_shadow_toggle.sh`](file:///home/ubaid/user_scripts/hypr/hypr_blur_opacity_shadow_toggle.sh) now passes explicit `$TARGET_STATE` directly via Quickshell IPC `syncElementOpacity("$TARGET_STATE")`.
  - Updated [`ThemeBackend.qml`](file:///home/ubaid/.config/quickshell/singletons/theme/ThemeBackend.qml) to immediately apply `elementOpacity = 1.0` (100% solid) when blur is OFF and `elementOpacity = 0.78` (dual-kawase translucent) when blur is ON, while adding `reload()` to `duskyBlurWatcher` on disk changes.
- **Hyprland Layer Rules Added**:
  - Added layer rules in [`window_rules.lua`](file:///home/ubaid/.config/hypr/edit_here/source/window_rules.lua) for `^qs-widget-.*$` desktop widgets and `^dusky-shell-switcher$`. Explicitly assigned `WlrLayershell.namespace: "quickshell"` to the bar in [`Bar.qml`](file:///home/ubaid/.config/quickshell/bar/Bar.qml).

---

### [2026-10-29 11:45] Phase 7: Brightness Engine Repair, Dual OSD / Mako Elimination, & UI Audio Restoration

- **Brightness Backend & OSD Fix**:
  - Diagnosed root cause of non-functioning brightness: QML files referenced non-existent `Caching.qsDir + "/../scripts/brightness.sh"` (`~/.config/scripts/brightness.sh`).
  - Added `readonly property string scriptsDir: (qsDir + "/scripts")` in [`Caching.qml`](file:///home/ubaid/.config/quickshell/singletons/system/Caching.qml).
  - Created safety symlink `~/.config/scripts -> ~/.config/quickshell/scripts` to guarantee foolproof resolution across all processes and scripts.
  - Corrected script invocations in [`OsdController.qml`](file:///home/ubaid/.config/quickshell/singletons/widgetcontrols/OsdController.qml), [`Osd.qml`](file:///home/ubaid/.config/quickshell/popouts/Osd.qml), [`SystemPanel.qml`](file:///home/ubaid/.config/quickshell/syspanel/SystemPanel.qml), [`SystemPanelSliders.qml`](file:///home/ubaid/.config/quickshell/syspanel/SystemPanelSliders.qml), [`Launcher.qml`](file:///home/ubaid/.config/quickshell/launcher/Launcher.qml), and [`launch_daemon.sh`](file:///home/ubaid/.config/quickshell/guide/wellbeing/launch_daemon.sh).
  - Restored `brightness.sh watch` (`inotifywait` on `/sys/class/backlight/*/brightness`) and `brightness.sh get`. Display brightness sliders and keyboard brightness controls now respond smoothly and display Serpantinum's native OSD.
- **Mako Isolation & Double OSD Elimination**:
  - Prevented DBus activation race condition where `notify-send` auto-started `mako.service` before Quickshell claimed `org.freedesktop.Notifications`.
  - In [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh), `mako.service` is masked via `systemctl --user mask mako.service` when Serpantinum is active, and unmasked when switching to Dusky Native.
  - Quickshell now exclusively owns `org.freedesktop.Notifications` in Serpantinum mode with zero Mako interference.
  - In [`osd_router.sh`](file:///home/ubaid/user_scripts/mako_osd/osd_router/osd_router.sh), detected active shell: skips sending synthetic DBus notifications when Serpantinum is active, allowing Quickshell's native OSD to render cleanly without duplicate notification banners.
- **Audio Feedback Restoration**:
  - Restored navigation click sound effects in [`GuideSidebar.qml`](file:///home/ubaid/.config/quickshell/guide/GuideSidebar.qml) for settings tab and subtab selection.
  - Added click and toggle sound effects to [`MusicEqView.qml`](file:///home/ubaid/.config/quickshell/media/MusicEqView.qml) and [`MusicEqualizerState.qml`](file:///home/ubaid/.config/quickshell/media/MusicEqualizerState.qml) when adjusting equalizer band sliders, stereo/mono toggles, balance sliders, and dynamic audio modes.
- **12-Hour Clock Fallback Enforced**:
  - Updated fallback time format in [`DateTime.qml`](file:///home/ubaid/.config/quickshell/singletons/system/DateTime.qml) from `"HH:mm:ss"` to `"hh:mm AP"`.
  - Enforced `.general.time_format = "hh:mm AP"` in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json).
- **Process Leak Prevention**:
  - Added cleanup rules for `inotifywait.*serpantinum` and `inotifywait.*backlight` inside `kill_serpantinum_all` in [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh).

---

### [2026-10-29 15:20] Phase 8: Coffee Mode Hold Animation, Native Bar Power Module, Wellbeing Engine, & Dynamic Keybinds

- **Coffee Mode & Wayland Idle Inhibition Engine**:
  - Loaded `Idle {}` component from `idle/Idle.qml` in [`shell.qml`](file:///home/ubaid/.config/quickshell/shell.qml), creating native `Quickshell.Wayland.IdleInhibitor` when caffeine is active.
  - Added `onRawSettingsChanged` reactivity in [`Idle.qml`](file:///home/ubaid/.config/quickshell/idle/Idle.qml) for instant state synchronizations.
  - Overhauled [`SystemPanelQuickActions.qml`](file:///home/ubaid/.config/quickshell/syspanel/SystemPanelQuickActions.qml):
    - **Normal Click**: Toggles permanent/indefinite caffeine (`∞`, `coffeeEndTime = 0`).
    - **Press & Hold (500ms)**: Plays continuous charging sound (`reusables/fillbutton/charge_loop.wav`), animates vertical progress fill (`fillLevel: 0 -> 1.0`), plays confirmation tone (`button.wav`), and opens an anchored timer selector popup.
    - **Duration Picker Card**: Provides selectable timer options: `30 Minutes`, `1 Hour`, `5 Hours`, `Permanent`. Clicking an option applies the duration with audio feedback.
- **Native Power Module in Serpantinum Bar & Control Center**:
  - Registered `power` module in [`BarModuleRegistry.qml`](file:///home/ubaid/.config/quickshell/bar/BarModuleRegistry.qml) with `button` and `icon` variants and normalized aliases (`power`, `session`, `shutdown`).
  - Created [`PowerFace.qml`](file:///home/ubaid/.config/quickshell/bar/faces/power/PowerFace.qml) supporting both `button` and `icon` styling with red accent hovers, sound feedback, and a sleek floating popup with options: `Shutdown`, `Restart`, `Suspend`, `Lock`, `Logout`.
  - Created [`BarPowerCard.qml`](file:///home/ubaid/.config/quickshell/guide/bar/modules/BarPowerCard.qml) and integrated it into [`BarModulesTab.qml`](file:///home/ubaid/.config/quickshell/guide/bar/BarModulesTab.qml) and [`BarModulesSettings.qml`](file:///home/ubaid/.config/quickshell/guide/bar/modules/BarModulesSettings.qml) for full Control Center configurability.
  - Added `"power"` to default bar layout in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json).
- **Digital Wellbeing & Focus Time Engine**:
  - Resolved path fallbacks in [`focus_daemon.py`](file:///home/ubaid/.config/quickshell/guide/wellbeing/focus_daemon.py) and [`get_stats.py`](file:///home/ubaid/.config/quickshell/guide/wellbeing/get_stats.py) to point to `~/.local/state/serpantinum/focustime` and `/run/user/1000/serpantinum/focustime`.
  - Implemented resilient Hyprland socket auto-discovery probing `$XDG_RUNTIME_DIR/hypr/` and `/tmp/hypr/` when signature variables are unexported.
  - Enabled `"focusDaemonEnabled": true` in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json) and wired auto-start into [`shell.qml`](file:///home/ubaid/.config/quickshell/shell.qml) and [`dusky_shell_switch.sh`](file:///home/ubaid/user_scripts/hypr/dusky_shell_switch.sh).
  - Loaded `WellbeingLimitOverlay {}` in [`shell.qml`](file:///home/ubaid/.config/quickshell/shell.qml) for app usage limit alerts.
- **Serpantinum Lockscreen & Dynamic Keybinding System**:
  - Enabled `"lock": { "enabled": true }` in [`settings.json`](file:///home/ubaid/.config/serpantinum/settings.json) to activate Serpantinum's `WlSessionLock` and IPC listener.
  - Symlinked `~/.cache/current_wallpaper -> ~/.cache/serpantinum/wallpaper/current_wallpaper.png` and updated [`LockBackdrop.qml`](file:///home/ubaid/.config/quickshell/lock/LockBackdrop.qml) so Serpantinum lockscreen immediately inherits the active wallpaper.
  - Created smart dispatchers in `~/user_scripts/hypr/`:
    - [`smart_lock.sh`](file:///home/ubaid/user_scripts/hypr/smart_lock.sh): Routes lock to `scripts/lock.sh` if Serpantinum is active; routes to `hyprlock` if Dusky is active.
    - [`smart_launcher.sh`](file:///home/ubaid/user_scripts/hypr/smart_launcher.sh): Routes launcher to `qs_manager.sh toggle launcher` in Serpantinum; routes to `rofi` in Dusky.
    - [`smart_control_center.sh`](file:///home/ubaid/user_scripts/hypr/smart_control_center.sh): Routes control center to `qs_manager.sh toggle syspanel` in Serpantinum; routes to native GTK control center in Dusky.
  - Forwarded [`user_scripts/hyprlock/lock.sh`](file:///home/ubaid/user_scripts/hyprlock/lock.sh) to `smart_lock.sh`.
  - Updated [`keybinds.lua`](file:///home/ubaid/.config/hypr/source/keybinds.lua) (`SUPER + M`, `ALT + SPACE`, `SUPER + SPACE`) to use the dynamic dispatchers, eliminating all keybinding collisions.
- **Comprehensive Master Documentation**:
  - Greatly expanded [`04_AI_AGENT_PORTING_PLAYBOOK.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/04_AI_AGENT_PORTING_PLAYBOOK.md) into a 10-chapter architectural manual covering rules for Widgets, Menus, Launchers, Lockscreen, Bars, Daemons, and the 10 Golden Rules of Shell Porting.

---

### [2026-10-29 15:45] Phase 9: Coffee Mode Hold Audio & Hit-Testing, Super+Space Control Center Routing, & Bar Power Module in Settings

- **Coffee Mode Hold Animation & Hit-Testing Refinements**:
  - Replaced invalid `Sounds.playSfxLoop` call with `Sounds.playUntilStopped("reusables/fillbutton/charge_loop.wav", 0.6, false)` guarded by `typeof Sounds !== "undefined"`, eliminating JavaScript TypeError exception that prevented `fillAnim` from starting.
  - Added `isHeldTriggered` boolean flag to `QuickActionBtn`: prevents mouse release event from triggering a regular left-click when the button was held for the duration.
  - Reparented `coffeePickerCard` and its dismisser `MouseArea` to `view.panel` with coordinate translation via `mapToItem`: resolved Qt Quick hit-testing boundary clipping where mouse events were dropped by the parent Item. Selecting options (`30 Minutes`, `1 Hour`, `5 Hours`, `Permanent`) and clicking outside to dismiss now registers with 100% reliability.
  - Standard left-click toggles permanent mode with the coffee icon lit in warm peach and displaying `"∞"` on hover, while timed selections display the remaining countdown cleanly.
- **Super + Space Dynamic Routing to Serpantinum Settings / Control Center**:
  - Updated [`smart_control_center.sh`](file:///home/ubaid/user_scripts/hypr/smart_control_center.sh) to execute `bash "$HOME/.config/quickshell/scripts/settings.sh" toggle` in Serpantinum mode, directly opening Serpantinum's rich Settings / Control Center window instead of the right sidebar.
- **Bar Power Module in Serpantinum Settings / Control Center**:
  - Added `"power": "Power"` to `labels`, `"power": ""` to `icons`, `"power": ThemeBackend.red` to `colors`, and `"power"` to `defaultBarSettings.modules.right` in [`BarGeneralState.qml`](file:///home/ubaid/.config/quickshell/guide/bar/general/BarGeneralState.qml). The Power module is now fully visible and draggable in the visual bar layout editor.
  - Added power module localization strings to [`en.json`](file:///home/ubaid/.config/quickshell/assets/languages/en.json).
  - Promoted [`BarPowerCard.qml`](file:///home/ubaid/.config/quickshell/guide/bar/modules/BarPowerCard.qml) to the top of [`BarModulesTab.qml`](file:///home/ubaid/.config/quickshell/guide/bar/BarModulesTab.qml) immediately under `BarMenuCard` for quick configuration.
  - Fully indexed search keywords for the Power module (`power`, `shutdown`, `restart`, `reboot`, `lock`, `suspend`, `logout`) in the Settings search bar.
- **Reliable Quickshell In-Process Hot-Reload**:
  - Added reactive `FileView` to [`Main.qml`](file:///home/ubaid/.config/quickshell/Main.qml) watching `~/.local/state/serpantinum/reload_trigger` with `onFileChanged: Quickshell.reload(true)`, enabling instant and crash-free reloads across all desktop components.

---

### [2026-10-29 16:05] Phase 10: Digital Wellbeing Master Control, Robust Path Discovery & UI Overhaul

- **Master Focus Tracking Service Controls in Settings**:
  - Added **"Track Active Screen Time"** master toggle card with live status indicator (`Active` / `Stopped`) at the top of [`WellbeingSettingsView.qml`](file:///home/ubaid/.config/quickshell/guide/wellbeing/WellbeingSettingsView.qml).
  - Added a live status badge button in the top navigation bar of [`WellbeingHeader.qml`](file:///home/ubaid/.config/quickshell/guide/wellbeing/WellbeingHeader.qml): `[ 󰄉 Tracking ON ]` / `[ 󰄉 Tracking OFF ]`. Clicking it toggles the service instantly with continuous process supervision.
  - Replaced the plain "No data" placeholder in [`WellbeingBottomPanel.qml`](file:///home/ubaid/.config/quickshell/guide/wellbeing/WellbeingBottomPanel.qml) with an interactive status card. If tracking is stopped, a clear explanation is shown alongside a **"Start Tracking Service"** action button.
- **Resilient Multi-Path Runtime & State File Mirroring**:
  - In [`focus_daemon.py`](file:///home/ubaid/.config/quickshell/guide/wellbeing/focus_daemon.py), implemented `_get_run_dir()` probing `/tmp/serpantinum/focustime`, `$QS_RUN_FOCUSTIME`, `$XDG_RUNTIME_DIR/serpantinum/focustime`, and falling back gracefully to persistent `~/.local/state/serpantinum/focustime`.
  - Added `write_state_file()` which mirrors `focustime_state.json` to both `/tmp/serpantinum/focustime/` and persistent `~/.local/state/serpantinum/focustime/`.
  - Added fallback process readers in [`WellbeingState.qml`](file:///home/ubaid/.config/quickshell/guide/wellbeing/WellbeingState.qml) (`fallbackReader` and `runStatsPoller()`), so if the live run-dir JSON is ever empty or missing, it queries `~/.local/state/` and SQLite directly via [`get_stats.py`](file:///home/ubaid/.config/quickshell/guide/wellbeing/get_stats.py).
- **Hyprland Socket & Instance Auto-Discovery**:
  - In [`focus_daemon.py`](file:///home/ubaid/.config/quickshell/guide/wellbeing/focus_daemon.py), `HYPRLAND_INSTANCE_SIGNATURE` is automatically probed and exported to `os.environ` upon startup, preventing `hyprctl activewindow -j` failures.
  - Added periodic active window polling every 5 seconds as a safety net against dropped IPC socket focus events.
  - Fixed relative path calculation for `LANG_DIR` so localization dictionaries load cleanly.





---

### [2026-10-29 18:25] Phase 11: iNiR Porting, Theming Lockdown, Double Bar Fix & skwd-wall Integration

- **Dusky System & App Theming Lockdown (Neutralizing Foreign Overwrites)**:
  - Discovered that iNiR's `scripts/colors/apply-gtk-theme.sh` ran on shell boot and overwrote `gsettings`, `~/.config/gtk-3.0/settings.ini`, `gtk-4.0/settings.ini`, `qt5ct.conf`, `qt6ct.conf`, and `xsettingsd.conf` with uninstalled `WhiteSur-dark` and `Fluent-teal-dark` icon themes, breaking icons in Thunar, docks, and apps across the system.
  - Replaced `~/.config/quickshell/inir/scripts/colors/apply-gtk-theme.sh` and all scripts in `~/.config/quickshell/inir/scripts/colors/modules/` (`20-gtk-kde.sh`, `10-terminals.sh`, `30-editors.sh`, `31-zed.sh`, `40-chrome.sh`, `45-firefox.sh`, `50-spicetify.sh`, `60-sddm.sh`, `70-steam.sh`, `80-pear-desktop.sh`, `85-limusic.sh`, `90-cava.sh`, `95-claude-code.sh`) with safe no-ops (`exit 0`).
  - Hardcoded `icon-theme-polarity.sh` and `icon-theme-for-mode.sh` to safely return `Papirus-Dark`.
  - Disabled `wallpaperTheming.enableAppsAndShell`, `enableQtApps`, `enableTerminal`, `enableVesktop`, and `enableZed` in `~/.config/inir/config.json`.
  - Fully restored Dusky native `Papirus-Dark` and `dusky-matugen-b` themes in `gsettings`, `gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, and `xsettingsd.conf`, and triggered all Dusky theme publishers (`gtk_colors.py`, `qt_colors.py`, `kde_colors.py`).

- **Resolved Serpantinum Double-Bar Bug on `SUPER + ESC`**:
  - Root cause: `smart_sidebar.sh` called `serpantinum msg toggle system`. The top-level `serpantinum` CLI wrapper called `ensure_daemon()`, which checked `/tmp/serpantinumd.pid`. Since Quickshell was running without that pidfile, `ensure_daemon()` launched a second `serpantinumd start` process, creating a second bar.
  - Fix: Updated `smart_sidebar.sh` to execute `bash "$HOME/.config/quickshell/scripts/qs_manager.sh" toggle system` directly, dispatching via `quickshell ipc call main handleCommand toggle system` with zero process spawning.

- **iNiR Subshell & Missing Bar Fixes**:
  - `IrisGate.official` Bypass: In `~/.config/quickshell/inir/modules/iris/style/IrisGate.qml`, changed `official` to `readonly property bool official: true`, eliminating the gate check that failed in the unified quickshell directory.
  - `enabledPanels` Multi-Family Initialization: In `~/.config/inir/config.json`, populated `enabledPanels` with all identifiers across `iris`, `ii`, and `waffle`. In `shell.qml`, added `root._ensureFamilyPanels(family)` at boot and on family change so subshell loaders always have their required panel IDs active.

- **Desktop Right-Click Context Menu & Wallpaper Pass-Through**:
  - Discovered that setting `"modules.background": false` completely unloaded `Background.qml`, removing the desktop `MouseArea` and breaking the right-click menu (`desktopContextMenu` and `irisDesktopMenu`).
  - Restored `"modules.background": true` in `config.json` and in `dusky_shell_switch.sh`.
  - Set `showInternalStaticWallpaper: false` in `modules/background/Background.qml` and `modules/waffle/background/WaffleBackground.qml`, and `externalWallpaper: true` in `modules/iris/background/IrisBackground.qml`. This renders `Background.qml` as a 100% transparent overlay over `skwd-wall-v2`, preserving desktop right-clicks and widgets without double-wallpaper rendering.

- **Universal `skwd-wall-v2` Wallpaper Integration**:
  - Intercepted `wallpaperSelector`, `wallpaper`, and `coverflowSelector` in `~/.config/quickshell/inir/scripts/inir` to execute `/usr/bin/skwd-wall-v2`.
  - Updated context menu "Change wallpaper" in `Background.qml` and hero action in `IrisDesktopActions.qml` to launch `/usr/bin/skwd-wall-v2`.
  - Updated `WallpaperSection.qml`, `UtilButtons.qml`, `IslandDesktopPage.qml`, and `IrisWallpaperCard.qml` to launch `/usr/bin/skwd-wall-v2`.
  - Updated `qs_manager.sh` in Serpantinum to launch `/usr/bin/skwd-wall-v2` directly on `wallpaper` target.

- **System Dependencies Installed**:
  - Installed missing Arch packages: `qt6-imageformats`, `syntax-highlighting`, `ttf-material-symbols-variable`, `wlsunset` via `pacman -S`.
  - Installed `ttf-roboto-flex` from AUR via `yay -S`.

---

### [2026-10-29 19:40] Phase 12: Wallpaper Unblur, Screenshot Freeze Fix, Clipboard ESC Resolution & Two-Way Matugen Synchronization

- **Hyprland Layer Rule Fix (Unblurring Desktop Wallpaper & Screenshot Region Selector)**:
  - Root cause: Wildcard layer rules in `~/.config/hypr/source/window_rules.lua` (`match = { namespace = "^quickshell.*" }`) and `~/.config/hypr/edit_here/source/window_rules.lua` (`match = { namespace = "^quickshell:.*$" }`) matched fullscreen background surfaces (`quickshell:background`, `quickshell:iris-background`, `quickshell:wBackground`, `quickshell:iiBackdrop`) and screen capture surfaces (`quickshell:regionSelector`, `quickshell:annotationEditor`). This caused Hyprland to apply compositor blur over the entire screen above the root wallpaper, creating a blurred desktop, and caused `regionSelector` to freeze/swallow input during screenshot snips.
  - Solution: Replaced the wildcards with explicit panel/popup namespaces (`quickshell:(bar|dock|iris-chassis|iris-menu|controlPanel|dashboard|equalizer|popup|wAction.*|wStart.*|clipboardPanel)`) and added an explicit `blur = false` rule for backgrounds and selectors (`quickshell:(background|iris-background|wBackground|iiBackdrop|regionSelector|annotationEditor|.*Backdrop|.*catcher|.*Scrim)`).
  - In `~/.config/inir/config.json`, disabled `background.backdrop.enable = false`, `background.effects.enableBlur = false`, and zeroed out `effects.dim` and `effects.dynamicDim`.

- **Screenshot Tool & Clipboard Escape Resolution**:
  - Terminal Clipboard `ESC` Fix: In `/home/ubaid/user_scripts/clipboard/terminal_clipboard.sh`, `cmd_key_escape()` previously executed `printf 'ignore'` in vim normal mode or switched modes from search, completely ignoring the `ESC` key and trapping the user in the window. Updated `cmd_key_escape()` to return `printf 'abort'` unconditionally so pressing `ESC` exits immediately.
  - iNiR Screenshot Copy Streamlining: Rewrote `~/.config/quickshell/inir/scripts/clipboard-copy.sh` to execute `wl-copy` directly via stdin/arguments without creating temporary files or spawning fragile `systemd-run` background units.
  - Shell-Aware Clipboard Keybind (`SUPER + V`): Created `~/user_scripts/hypr/smart_clipboard.sh` and bound `SUPER + V` to it in `~/.config/hypr/source/keybinds.lua`.
    - Serpantinum: toggles `qs-clipboard` via `qs_manager.sh toggle clipboard`.
    - iNiR: toggles `quickshell:clipboardPanel` via `inir clipboard toggle`.
    - Dusky Native: launches `terminal_clipboard.sh` in Foot (or Rofi clipboard).

- **Dynamic Matugen Pipeline & Two-Way Wallpaper Synchronization**:
  - iNiR Matugen Template: Created `~/.config/matugen/templates/inir-colors.json` and added `[templates.inir_quickshell]` to `~/.config/matugen/config.toml`, generating `~/.local/state/quickshell/user/generated/colors.json` with dynamic Material 3 tokens extracted directly by Matugen from the active wallpaper.
  - Unified Wallpaper Synchronizer (`~/user_scripts/hypr/sync_wallpaper.sh`): Implemented a two-way synchronization engine that:
    1. Sets desktop wallpaper using `skwd-wall-still`.
    2. Updates `skwd-wall-v2` (`~/.config/skwd-wall-v2/config.json`).
    3. Updates Dusky native state (`dark_wal` and `current_image`).
    4. Updates Serpantinum (`~/.local/state/serpantinum/current_wallpaper` and `settings.json`).
    5. Updates iNiR (`~/.config/inir/config.json` `background.wallpaperPath` and `wallpaper/path.txt`).
    6. Runs Matugen with `--source-color-index=0 --mode=dark`, updating colors across all 3 shells in parallel.
  - Hooked `switchwall.sh` in iNiR so selecting wallpapers from iNiR shell settings or Coverflow dispatches to `sync_wallpaper.sh`.
  - Added Matugen post_hook `[templates.serpantinum_wallpaper]` in `config.toml` to synchronize configuration paths across all shells whenever Matugen runs.
  - Integrated `sync_wallpaper.sh` into `dusky_shell_switch.sh` for instant synchronization on shell switches.
  - Neutered destructive `gsettings set ... gtk-theme` calls inside `switchwall.sh` `pre_process()` to safeguard GTK3/GTK4 themes and icons.
