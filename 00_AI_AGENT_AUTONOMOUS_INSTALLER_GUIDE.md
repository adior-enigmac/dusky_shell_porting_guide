# Autonomous AI Agent Installer Guide: Full Multi-Shell Deployment on Fresh Dusky Linux

> [!IMPORTANT]
> ### 🤖 PRIMARY DIRECTIVE FOR THE AI AGENT READING THIS GUIDE
> You are an autonomous AI coding assistant. The user has provided you the path to this guide on a **fresh, clean Dusky Linux installation** (Arch Linux + Hyprland + Waybar + `skwd-wall-v2`).
> Your objective is to follow this guide step-by-step from A to Z to deploy, patch, safely merge, and verify the **exact production-grade Dusky Multi-Shell Ecosystem** identical to Ubaid's setup:
> 1. **Dusky Native Shell** (Waybar + Mako + GTK Control Center + Rofi)
> 2. **Serpantinum Shell** (Quickshell Bar, Floating Dock, Desktop Widgets, Quickactions Sidebar, Spotlight Clipboard, System Panel)
> 3. **iNiR Desktop Shell** with 3 fully working subshells:
>    - **iRiS (Default)**: Dynamic Island, morphing controls, IrisPalette.
>    - **Material ii**: Top M3 bar, app dock, left AI/music sidebar, right quick settings drawer.
>    - **Waffle**: Windows 11 style bottom taskbar, start menu, action center.
>
> ### 🛡️ THE THREE CARDINAL SAFETY RULES
> 1. **MANDATORY PRE-FLIGHT BACKUP & SAFE ROLLBACK**: Never modify any user file without first creating a timestamped backup. If any command fails, any syntax error occurs, or Quickshell segfaults, **immediately execute a safe rollback** to restore the user's files and reload the system cleanly!
> 2. **SMART NON-DESTRUCTIVE MERGING (NEVER OVERWRITE USER CONFIGS)**: The user already has their own custom keybindings, window rules, and dozens of Matugen application templates in `~/.config/hypr/` and `~/.config/matugen/config.toml`. **Never overwrite or replace user config files!** Safely merge the required snippets using `safe_config_merger.py --merge` or append only the missing entries.
> 3. **IF YOU GET STUCK, CONSULT UBAID'S JOURNEY DOCS**: If you encounter confusing behavior, crashes, or uncooperative widgets, **do not guess!** Go directly into the dedicated subshell documentation folders (`serpantinum/` and `inir/`). Those documents capture Ubaid's entire development journey, root cause discoveries, and battle-tested workarounds.

---

## Remote Git Repositories

Clone these staging repositories during installation:
* **Serpantinum**: `https://github.com/ilyamiro/serpantinum.git`
* **iNiR**: `https://github.com/snowarch/iNiR`

---

## 1. Zero-Risk Pre-Flight Backup & Rollback Protocol

Before touching or editing ANY user files, initialize an archived backup.

### 1.1 Create Pre-Flight Backup
Use the bundled helper script to archive the user's current configuration:
```bash
python3 <guide_path>/bundle/scripts/safe_config_merger.py --backup
```
* **Target backup directory**: `~/.config/dusky_multishell_backups/backup_<YYYYMMDD_HHMMSS>/`
* **Preserved files**:
  - `~/.config/hypr/source/keybinds.lua`
  - `~/.config/hypr/source/window_rules.lua`
  - `~/.config/hypr/edit_here/source/keybinds.lua` (if present)
  - `~/.config/hypr/edit_here/source/window_rules.lua` (if present)
  - `~/.config/matugen/config.toml` (if present)
  - `~/.config/serpantinum/settings.json` (if present)
  - `~/.config/inir/config.json` (if present)
  - `manifest.json` (full inventory of original paths and destinations)

### 1.2 Emergency Rollback Command
If an unrecoverable error occurs at any point during installation:
```bash
python3 <guide_path>/bundle/scripts/safe_config_merger.py --rollback
```
This restores all files from the latest backup, validates Lua and TOML syntax, and reloads Hyprland cleanly (`hyprctl reload`).

---

## 2. System Requirements & Dependency Installation

### 2.1 Dependency Audit
Verify which packages and utilities are already present:
```bash
which quickshell qs hyprctl matugen cava socat jq wireplumber brightnessctl playerctl grim slurp wl-copy cliphist foot rofi luac 2>/dev/null
```

### 2.2 Package Installation
If any packages are missing, install them. **If root permissions are required, prompt the user for their `sudo` password.**
```bash
# Official Arch repositories
sudo pacman -S --needed \
    quickshell cava matugen socat jq wireplumber brightnessctl playerctl \
    grim slurp wl-copy cliphist foot rofi-wayland \
    qt6-imageformats qt6-multimedia-ffmpeg syntax-highlighting wlsunset \
    qt6-declarative qt6-svg lua

# AUR Fonts & Extensions (via yay)
yay -S --needed \
    ttf-roboto-flex ttf-material-symbols-variable ttf-font-awesome ttf-jetbrains-mono-nerd
```

---

## 3. Workspace Setup & Repository Cloning

Clone the upstream payloads into a temporary staging workspace:
```bash
STAGING_DIR="/tmp/dusky_shell_staging"
mkdir -p "$STAGING_DIR"
cd "$STAGING_DIR"

# Clone Serpantinum
[[ -d "$STAGING_DIR/serpantinum" ]] || git clone https://github.com/ilyamiro/serpantinum.git "$STAGING_DIR/serpantinum"

# Clone iNiR
[[ -d "$STAGING_DIR/inir" ]] || git clone https://github.com/snowarch/iNiR "$STAGING_DIR/inir"
```

> [!CAUTION]
> **NO SYMLINKS TO STAGING**: Always physically copy payloads from staging to their final directories (`~/.config/quickshell/` and `~/.config/quickshell/inir/`). The user will delete `/tmp/dusky_shell_staging` after setup!

---

## 4. Deploying Core Bundle Scripts & Dispatchers

Locate the `bundle/scripts/` folder inside this porting guide directory (`<guide_path>/bundle/scripts/`) and deploy all scripts to `~/user_scripts/hypr/`:

```bash
mkdir -p "$HOME/user_scripts/hypr"
cp -f <guide_path>/bundle/scripts/* "$HOME/user_scripts/hypr/"
chmod +x "$HOME/user_scripts/hypr"/*.sh "$HOME/user_scripts/hypr"/*.py
```

### Verified Script Inventory & Responsibilities:
1. `dusky_shell_switcher.py`: GTK LayerShell animated GUI menu (`SUPER + CTRL + S` or numeric keys `1-5`).
2. `dusky_shell_switch.sh`: Conflict-free CLI switching engine (`--dusky`, `--serpantinum`, `--inir-iris`, `--inir-ii`, `--inir-waffle`).
3. `safe_config_merger.py`: Non-destructive configuration merger, pre-flight backup, and atomic rollback engine.
4. `smart_launcher.sh`: Application launcher dispatcher (`ALT + SPACE`).
5. `smart_control_center.sh`: System control center dispatcher (`SUPER + SPACE`).
6. `smart_sidebar.sh`: Sidebar / Quickactions drawer dispatcher (`SUPER + ESC`).
7. `smart_lock.sh`: Screen lock dispatcher (`SUPER + M`).
8. `smart_clipboard.sh`: Rich clipboard dispatcher (`SUPER + V`).
9. `sync_wallpaper.sh`: Bidirectional wallpaper & Matugen palette synchronizer.

---

## 5. Deploying & Configuring Serpantinum

### 5.1 Physical Filesystem Layout
Copy the Serpantinum payload into the root Quickshell directory:
```bash
mkdir -p "$HOME/.config/quickshell"
cp -r "$STAGING_DIR/serpantinum/quickshell"/* "$HOME/.config/quickshell/"
cp -r "$STAGING_DIR/serpantinum/scripts" "$HOME/.config/quickshell/"
cp -r "$STAGING_DIR/serpantinum/assets" "$HOME/.config/quickshell/"
chmod +x "$HOME/.config/quickshell/scripts"/*.sh "$HOME/.config/quickshell/scripts"/*.py 2>/dev/null || true
```

### 5.2 Standalone Binaries
Install Serpantinum CLI binaries into `~/.local/bin/`:
```bash
mkdir -p "$HOME/.local/bin"
cp -f "$STAGING_DIR/serpantinum/bin/serpantinum" "$HOME/.local/bin/serpantinum" 2>/dev/null || true
cp -f "$STAGING_DIR/serpantinum/bin/serpantinumd" "$HOME/.local/bin/serpantinumd" 2>/dev/null || true
chmod +x "$HOME/.local/bin/serpantinum" "$HOME/.local/bin/serpantinumd"
```

### 5.3 Configuration (`~/.config/serpantinum/settings.json`)
Create `~/.config/serpantinum/settings.json` with the required parameters:
```json
{
  "bar": { "enabled": true, "position": "top" },
  "dock": { "enabled": true, "position": "bottom", "smartAutohide": true },
  "widgets": { "enabled": true },
  "launcher": { "enabled": true },
  "clipboard": { "enabled": true },
  "notifications": { "enabled": true },
  "lock": { "enabled": true },
  "popouts": { "enabled": true },
  "wallpaper": { "enabled": false },
  "general": {
    "focusDaemonEnabled": true,
    "quickactions": true
  }
}
```
*(Notice: `wallpaper.enabled = false` is mandatory so that `skwd-wall-v2` retains ownership of the background!)*

### 5.4 Mandatory Code Patches for Serpantinum
Apply the following battle-tested patches:

#### Patch 1: Robust Toggle & Screen Fallback in `ClipboardController.qml` & `LauncherController.qml`
In `~/.config/quickshell/singletons/widgetcontrols/ClipboardController.qml` and `LauncherController.qml`, replace `show()` and `toggle()` with:
```qml
    function show(scr) {
        let target = getScreen(scr);
        if (target !== null && target !== undefined) {
            controller.screen = target;
        } else {
            let focused = getFocusedScreen();
            if (focused !== null && focused !== undefined) {
                controller.screen = focused;
            } else if (typeof Quickshell !== "undefined" && Quickshell.screens && Quickshell.screens.length > 0) {
                controller.screen = Quickshell.screens[0];
            }
        }
        controller.isVisible = true;
    }

    function hide() {
        controller.isVisible = false;
    }

    function toggle(scr) {
        if (controller.isVisible) {
            hide();
        } else {
            show(scr);
        }
    }
```

#### Patch 2: Escape Key Handler in `clipboard/Clipboard.qml`
In `~/.config/quickshell/clipboard/Clipboard.qml`, add an `Escape` handler to the root `PanelWindow`:
```qml
    Keys.onEscapePressed: function(event) {
        closeClipboard();
        event.accepted = true;
    }
```

#### Patch 3: Clipboard Button in TopBar (`bar/faces/left/LeftFace.qml`)
In `~/.config/quickshell/bar/faces/left/LeftFace.qml`, add a dedicated clipboard button:
```qml
        MenuButton {
            id: clipboardBtn
            visible: true
            glyph: "󰅍"
            onClicked: if (!root.isPreview) Quickshell.execDetached(["bash", "-c", Caching.serpantinumDir + "/scripts/qs_manager.sh toggle clipboard"])
        }
```

#### Patch 4: Quick Action Tile in Control Center (`syspanel/SystemPanelQuickActions.qml`)
In `~/.config/quickshell/syspanel/SystemPanelQuickActions.qml`, add the clipboard tile:
```qml
        QuickActionBtn {
            id: clipboardBtn
            iconText: "󰅍"
            activeColor: ThemeBackend.mauve
            isActive: false

            onLeftClicked: {
                Sounds.playSfx("system/quick_click.wav");
                view.panel.closeAnim.start();
                Quickshell.execDetached(["bash", Caching.serpantinumDir + "/scripts/qs_manager.sh", "toggle", "clipboard"]);
            }
        }
```

#### Patch 5: Floating Sidebar Toggle in `FloatingController.qml` & `Floating.qml`
* In `~/.config/quickshell/singletons/widgetcontrols/FloatingController.qml`:
  - Add signal: `signal toggleRequested(var screen)`
  - Add function: `function toggle(screen) { let target = targetScreen(screen); if (target) controller.toggleRequested(target); }`
  - In `IpcHandler { target: "floating" }`: add `function toggle(): void { controller.toggle(null); }`
* In `~/.config/quickshell/quickactions/Floating.qml`:
  - Add connection:
    ```qml
    function onToggleRequested(screen) {
        if (floatingWidget.matchesScreen(screen)) {
            if (floatingWidget.isSidebarVisible) {
                floatingWidget.isSidebarVisible = false;
                floatingWidget.isExpanded = false;
            } else {
                floatingWidget.isSidebarVisible = true;
                floatingWidget.isExpanded = true;
            }
        }
    }
    ```

---

## 6. Deploying & Configuring iNiR

### 6.1 Physical Filesystem Layout
Copy iNiR into the isolated subdirectory `~/.config/quickshell/inir/`:
```bash
mkdir -p "$HOME/.config/quickshell/inir"
cp -r "$STAGING_DIR/inir"/* "$HOME/.config/quickshell/inir/"
find "$HOME/.config/quickshell/inir/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true
```

### 6.2 Standalone Binary
Create the `inir` launcher in `~/.local/bin/inir`:
```bash
cat << 'EOF' > "$HOME/.local/bin/inir"
#!/usr/bin/env bash
export INIR_RUNTIME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir"
exec "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir/scripts/inir" "$@"
EOF
chmod +x "$HOME/.local/bin/inir"
```

### 6.3 Configuration (`~/.config/inir/config.json`)
Initialize `~/.config/inir/config.json`:
```json
{
  "panelFamily": "iris",
  "modules": {
    "background": true
  },
  "wallpaperTheming": {
    "enableAppsAndShell": false
  },
  "theming": {
    "enableQtApps": false,
    "enableTerminal": false
  }
}
```
*(Notice: `modules.background = true` is required so the transparent canvas captures right-click desktop menus!)*

### 6.4 Mandatory Code Patches for iNiR

#### Patch 1: Lock Down Theme Scripts (Protect Dusky App Theming)
Neuter foreign color scripts that overwrite GTK/Qt/Papirus themes:
```bash
printf '#!/usr/bin/env bash\nexit 0\n' > "$HOME/.config/quickshell/inir/scripts/colors/apply-gtk-theme.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$HOME/.config/quickshell/inir/scripts/colors/20-gtk-kde.sh"
chmod +x "$HOME/.config/quickshell/inir/scripts/colors"/*.sh
```

#### Patch 2: Fix Toplevel Lifecycle Segfault 11 (`QQmlMetaType::propertyCache`)
* In `~/.config/quickshell/inir/services/CompositorService.qml:314`:
  ```javascript
  const liveToplevels = new Set(ToplevelManager.toplevels?.values ?? [])
  return ordered.map(x => x.wayland).filter(w => w !== null && w !== undefined && liveToplevels.has(w))
  ```
* In `~/.config/quickshell/inir/services/AppSearch.qml:582`:
  Wrap `resolveWindowIdentity(toplevel)` in `try { ... } catch (e) { return "" }`.
* In `~/.config/quickshell/inir/services/TaskbarApps.qml:128`:
  Wrap the open window iteration loop in `try { ... } catch (e) { continue; }`.

#### Patch 3: Fix Lock Button in Island & Quick Panels
In `~/.config/quickshell/inir/modules/common/functions/Session.qml`, ensure `Session.lock()` dispatches cleanly:
```qml
function lock(): void {
    if (Config?.options?.lock?.useHyprlock ?? false) {
        Quickshell.execDetached([Quickshell.env("HOME") + "/user_scripts/hypr/smart_lock.sh"]);
    } else {
        GlobalStates.screenLocked = true;
    }
}
```

#### Patch 4: Connect Wallpaper Selector to `skwd-wall-v2`
In `~/.config/quickshell/inir/modules/wallpaper/WallpaperSelectorRouter.qml`:
Replace internal wallpaper picker execution with:
```qml
Quickshell.execDetached(["/usr/bin/skwd-wall-v2"]);
```

---

## 7. Intelligent Non-Destructive Configuration Merging

> [!CAUTION]
> **CRITICAL RULE**: Do not copy/paste whole files over the user's `keybinds.lua`, `window_rules.lua`, or `matugen/config.toml`!
> The user has custom bindings, window rules for their favorite apps, and complex Matugen themes. You must **merge** the snippets non-destructively.

### 7.1 Automated One-Command Merge (Recommended)
Run the bundled merger to automatically back up, inspect, append missing entries, and verify syntax:
```bash
python3 <guide_path>/bundle/scripts/safe_config_merger.py --merge
```

### 7.2 Manual Non-Destructive Merge Steps
If performing the merge manually:

#### A. Hyprland Keybindings (`~/.config/hypr/edit_here/source/keybinds.lua`)
Check if the dispatchers are already present. If not, append this block:
```lua
-- ==============================================================================
-- DUSKY MULTI-SHELL SMART DISPATCHERS (AUTOMATICALLY MERGED)
-- ==============================================================================
local dusky_scripts = os.getenv("HOME") .. "/user_scripts/"

-- Application Launcher (Alt + Space)
hl.bind("ALT, SPACE", hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_launcher.sh"), { description = "Smart Launcher" })

-- Universal Control Center (Super + Space)
hl.bind("SUPER, SPACE", hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_control_center.sh"), { description = "Smart Control Center" })

-- Universal Sidebar / Fullscreen Toggle (Super + Esc)
hl.bind("SUPER, ESCAPE", hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_sidebar.sh"), { description = "Smart Sidebar" })

-- Universal Screen Lock (Super + M)
hl.bind("SUPER, M", hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_lock.sh"), { description = "Smart Screen Lock" })

-- Universal Clipboard History (Super + V)
hl.bind("SUPER, V", hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_clipboard.sh"), { description = "Smart Clipboard" })

-- Universal Desktop Shell Switcher GUI (Super + Ctrl + S)
hl.bind("SUPER + CTRL, S", hl.dsp.exec_cmd(dusky_scripts .. "hypr/dusky_shell_switcher.py"), { description = "Shell Switcher Menu" })
```
*Validate syntax immediately*: `luac -p ~/.config/hypr/edit_here/source/keybinds.lua`

#### B. Hyprland Layer Rules (`~/.config/hypr/edit_here/source/window_rules.lua`)
Check if multi-shell layer rules exist. If not, append the snippet from `<guide_path>/bundle/templates/hyprland_window_rules_snippet.lua`.
*Validate syntax immediately*: `luac -p ~/.config/hypr/edit_here/source/window_rules.lua`

#### C. Matugen Templates (`~/.config/matugen/config.toml`)
Check if `[templates.serpantinum_quickshell]` and `[templates.inir_quickshell]` exist. If missing, append the snippet from `<guide_path>/bundle/templates/matugen_config_snippet.toml`.
*Validate syntax immediately*:
```bash
python3 -c "import tomllib; tomllib.load(open('$HOME/.config/matugen/config.toml', 'rb'))"
```

---

## 8. Matugen Dynamic Palette Configuration & First Run

1. Copy dynamic template definitions into Matugen's templates folder:
```bash
mkdir -p "$HOME/.config/matugen/templates"
cp -f <guide_path>/bundle/templates/inir-colors.json "$HOME/.config/matugen/templates/"
cp -f <guide_path>/bundle/templates/serpantinum_matugen_colors.json.template "$HOME/.config/matugen/templates/"
```

2. Trigger an immediate palette generation from the active wallpaper:
```bash
CURRENT_WALL=$(cat ~/.cache/current_wallpaper 2>/dev/null || find ~/Pictures/Wallpapers/ -type f | head -n 1)
[[ -n "$CURRENT_WALL" ]] && matugen image "$CURRENT_WALL" 2>/dev/null || true
```

---

## 9. Verification & Test Matrix

Run this complete test suite to verify that every shell, subshell, and button functions cleanly:

```bash
# 1. Test Serpantinum
~/user_scripts/hypr/dusky_shell_switch.sh --serpantinum 1
sleep 2
# Verify single shell process (must show only Serpantinum under quickshell)
ps aux | grep -E "quickshell|qs " | grep -v "duskytunes" | grep -v grep
# Test Control Center toggle
~/user_scripts/hypr/smart_control_center.sh
sleep 1
~/user_scripts/hypr/smart_control_center.sh
# Test Clipboard toggle
~/user_scripts/hypr/smart_clipboard.sh
sleep 1
~/user_scripts/hypr/smart_clipboard.sh
# Test Sidebar toggle
~/user_scripts/hypr/smart_sidebar.sh
sleep 1
~/user_scripts/hypr/smart_sidebar.sh

# 2. Test iNiR iRiS
~/user_scripts/hypr/dusky_shell_switch.sh --inir-iris 1
sleep 2
# Verify single shell process (must show only qs ~/.config/quickshell/inir)
ps aux | grep -E "quickshell|qs " | grep -v "duskytunes" | grep -v grep
~/user_scripts/hypr/smart_control_center.sh
sleep 1
~/user_scripts/hypr/smart_control_center.sh
~/user_scripts/hypr/smart_clipboard.sh
sleep 1
~/user_scripts/hypr/smart_clipboard.sh

# 3. Test iNiR Material ii
~/user_scripts/hypr/dusky_shell_switch.sh --inir-ii 1
sleep 2
~/user_scripts/hypr/smart_control_center.sh
sleep 1
~/user_scripts/hypr/smart_control_center.sh

# 4. Test iNiR Waffle
~/user_scripts/hypr/dusky_shell_switch.sh --inir-waffle 1
sleep 2
~/user_scripts/hypr/smart_control_center.sh
sleep 1
~/user_scripts/hypr/smart_control_center.sh

# 5. Return to iNiR iRiS Default
~/user_scripts/hypr/dusky_shell_switch.sh --inir-iris 1
```

---

## 10. "If You Get Stuck" — The Deep Journey Knowledge Base

> [!TIP]
> ### 🧭 UBAID'S PORTING JOURNEY & ARCHITECTURAL ARCHIVES
> If any component behaves unexpectedly, throws an unhandled exception, or fails to initialize, **do not guess!**
> This repository contains the complete written record of Ubaid's real-world engineering journey solving these exact issues. Read the dedicated documentation for the target shell:

### 10.1 Serpantinum Deep Architecture
* [`serpantinum/00_SERPANTINUM_PORTING_MASTER.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/00_SERPANTINUM_PORTING_MASTER.md): High-level system overview, directory layouts, and design contracts.
* [`serpantinum/01_BAR_SWITCHER_GUIDE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/01_BAR_SWITCHER_GUIDE.md): Modular top bar switching architecture and layout persistence.
* [`serpantinum/02_MATUGEN_THEMING.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/02_MATUGEN_THEMING.md): Deep-dive into Serpantinum's `ThemeBackend` and dynamic color caching.
* [`serpantinum/03_HYPRLAND_CONFIG.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/03_HYPRLAND_CONFIG.md): Lua window rules, namespaces, and focus handling.
* [`serpantinum/04_CONTROL_CENTER_AND_FOCUS.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/04_CONTROL_CENTER_AND_FOCUS.md): `qs-master` system panel animations and focus management.
* [`serpantinum/05_DESKTOP_WIDGETS_AND_REDACTOR.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/05_DESKTOP_WIDGETS_AND_REDACTOR.md): Interactive widget redactor and desktop coordinates.
* [`serpantinum/06_DESKTOP_RIGHT_CLICK_MENU.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/06_DESKTOP_RIGHT_CLICK_MENU.md): Transparent canvas pass-through preserving right-click menus.
* [`serpantinum/07_BLUR_AND_SOLID_MODE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/07_BLUR_AND_SOLID_MODE.md): Solid vs translucent material switching.
* [`serpantinum/08_TASKS_AND_ARCHITECTURE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/08_TASKS_AND_ARCHITECTURE.md): Focus daemons, wellbeing trackers, and background tasks.

### 10.2 iNiR Deep Architecture
* [`inir/00_INIR_PORTING_MASTER.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/00_INIR_PORTING_MASTER.md): Unified subshell design (`iris`, `ii`, `waffle`).
* [`inir/01_SUBSHELLS_ARCHITECTURE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/01_SUBSHELLS_ARCHITECTURE.md): `panelFamily` state transitions and module loading.
* [`inir/02_IPC_AND_COMMANDS_REFERENCE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/02_IPC_AND_COMMANDS_REFERENCE.md): Exhaustive CLI IPC command dictionary.
* [`inir/03_WALLPAPER_AND_THEMING_COORDINATION.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/03_WALLPAPER_AND_THEMING_COORDINATION.md): Dynamic island color coordination and palette generation.
* [`inir/04_HYPRLAND_COMPATIBILITY_ENGINE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/04_HYPRLAND_COMPATIBILITY_ENGINE.md): CompositorService lifecycle guards and Segfault 11 prevention.

### 10.3 Universal Engine & Master Historical Log
* [`01_UNIVERSAL_SWITCHER_ENGINE.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/01_UNIVERSAL_SWITCHER_ENGINE.md): Process lifecycle, state management, and GTK LayerShell menu.
* [`02_SMART_DISPATCHERS_AND_DYNAMIC_KEYBINDS.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/02_SMART_DISPATCHERS_AND_DYNAMIC_KEYBINDS.md): Shell-aware routing mechanics.
* [`04_AI_AGENT_PORTING_PLAYBOOK.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/04_AI_AGENT_PORTING_PLAYBOOK.md): The 8-phase porting playbook and 10 Golden Rules.
* [`05_CHANGELOG.md`](file:///home/ubaid/Public/dusky_shell_porting_guide/05_CHANGELOG.md): Historical step-by-step engineering log recording every error discovered and solved.

---

## 11. Diagnostic Playbook & Troubleshooting Solutions

### 11.1 When to Trigger an Automatic Rollback
If any of these conditions occur and cannot be solved after 2 attempts:
1. `luac -p` reports syntax errors in Hyprland configuration.
2. `tomllib` reports parse errors in `~/.config/matugen/config.toml`.
3. Quickshell crashes immediately upon launching any shell.
**Command**:
```bash
python3 ~/user_scripts/hypr/safe_config_merger.py --rollback
```
Report the rollback details to the user and explain the cause.

### 11.2 Sudo Password Prompting
* **Symptom**: Commands like `sudo pacman` hang or request root authentication.
* **Remedy**: Never attempt to bypass authentication. Pause and prompt the user directly:
  > *"I need root privileges to install the required system packages (`quickshell`, `matugen`, etc.). Please provide your `sudo` password or run `sudo pacman -S ...` in your terminal."*

### 11.3 Missing AUR Helper (`yay` or `paru`)
* **Symptom**: `yay: command not found` when installing fonts or `matugen-bin`.
* **Remedy**: Bootstrap `yay-bin` automatically:
  ```bash
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin && makepkg -si --noconfirm
  rm -rf /tmp/yay-bin
  ```

### 11.4 Quickshell Segfault 11 on Window Close (`QQmlMetaType::propertyCache`)
* **Symptom**: Quickshell crashes immediately when a window closes, logging `QV4::QObjectWrapper::create` or `QQmlMetaType::propertyCache` in `~/.cache/quickshell/crashes/`.
* **Root Cause**: `Hyprland.toplevels` holds a dead C++ pointer. When QML models iterate over `sortedToplevels`, passing a freed pointer causes Qt to dereference freed memory.
* **Remedy**:
  1. In `~/.config/quickshell/inir/services/CompositorService.qml`:
     Filter `ordered.map(x => x.wayland)` against `liveToplevels = new Set(ToplevelManager.toplevels?.values ?? [])`.
  2. In `~/.config/quickshell/inir/services/AppSearch.qml`:
     Wrap `resolveWindowIdentity(toplevel)` in `try { ... } catch (e) { return "" }`.
  3. In `~/.config/quickshell/inir/services/TaskbarApps.qml`:
     Wrap the window iteration loop in `try { ... } catch (e) { continue; }`.

### 11.5 Dual-Process Ghost Shells (Waffle and Serpantinum running together)
* **Symptom**: Two bars or docks appear simultaneously on screen.
* **Root Cause**: Serpantinum was invoked via `quickshell`, while iNiR was invoked via `qs` (`/usr/bin/qs`). A simple `pkill -f quickshell` misses `qs`, leaving the previous shell alive.
* **Remedy**:
  Ensure process teardown in `dusky_shell_switch.sh` uses dual-regex:
  ```bash
  pkill -9 -f "(/usr/bin/)?(qs|quickshell).*(inir)" 2>/dev/null || true
  pkill -9 -f "(/usr/bin/)?(qs|quickshell)( |$)" 2>/dev/null || true
  ```

### 11.6 Blurred Wallpaper or Frozen Screenshot Selector
* **Symptom**: Changing wallpaper results in a heavily blurred screen, or screenshot tools freeze.
* **Root Cause**: Catch-all layer rule `match = { namespace = "^quickshell.*" }` with `blur = true`.
* **Remedy**:
  In `~/.config/hypr/edit_here/source/window_rules.lua`, ensure only interactive floating cards are blurred:
  ```lua
  hl.layerrule({ name = "blur", match = { namespace = "^(qs-master|qs-clipboard|qs-floating-overlay|quickshell:inir-.*|quickshell:iris-.*)$" } })
  hl.layerrule({ name = "noanim", match = { namespace = "^(desktop-backdrop|quickshell:background)$" } })
  ```

### 11.7 Workspace Switcher Jumps to Workspace 2 on Shell Switch
* **Symptom**: Switching between Serpantinum and iNiR throws the user onto Workspace 2.
* **Root Cause**: `focus_on_close = 0` in Hyprland reallocates focus to the next active surface when a full-screen layer unmaps. Legacy `hyprctl dispatch workspace N` fails on Hyprland 0.55+ with a Lua syntax error.
* **Remedy**:
  Use modern Lua syntax: `hyprctl dispatch 'hl.dsp.focus({ workspace = "'"$TARGET_WS"'" })'`. Fire the command immediately upon unmapping foreign layers, and repeat at 150ms, 500ms, and 1000ms deferred intervals.

### 11.8 Desynchronized Colors
* **Symptom**: Wallpapers change via `skwd-wall-v2`, but shell widgets keep old colors.
* **Remedy**:
  Verify Matugen output files exist:
  ```bash
  ls -l ~/.config/inir/colors.json ~/.config/quickshell/assets/matugen/colors.json
  ```
  If missing, run the synchronizer manually:
  ```bash
  ~/user_scripts/hypr/sync_wallpaper.sh
  ```

---

## 12. Reference Visual Gallery (Gold Standard State)

Compare the live desktop against the reference screenshots in `<guide_path>/assets/screenshots/`:

| Component / Subshell | Reference File | Visual Key Indicators |
| :--- | :--- | :--- |
| **Dusky Native Desktop** | `assets/screenshots/dusky_native_desktop.png` | Top Waybar, bottom dock, Papirus dark theme |
| **Serpantinum Desktop** | `assets/screenshots/serpantinum_desktop.png` | Top modular bar, bottom dynamic dock, desktop widgets |
| **Serpantinum Control Center** | `assets/screenshots/serpantinum_control_center.png` | Right drawer, volume slider, quick action tiles (`󰅍` clipboard) |
| **Serpantinum Sidebar** | `assets/screenshots/serpantinum_sidebar.png` | Right quickactions overlay, media controls |
| **Serpantinum Clipboard** | `assets/screenshots/serpantinum_clipboard.png` | Centered spotlight search, copy history items |
| **Serpantinum Settings** | `assets/screenshots/serpantinum_settings.png` | Dedicated settings window with category navigation |
| **iNiR iRiS Desktop** | `assets/screenshots/inir_iris_desktop.png` | Dynamic Island pill top-center, clean desktop canvas |
| **iNiR iRiS Control Center** | `assets/screenshots/inir_iris_control_center.png` | Minimalist popdown panel with quick toggles & sliders |
| **iNiR iRiS Island Expanded** | `assets/screenshots/inir_iris_island_open.png` | Dynamic island morphing into expanded dashboard pill |
| **iNiR iRiS Clipboard** | `assets/screenshots/inir_iris_clipboard.png` | Fluent centered card list with search bar |
| **iNiR Material ii Desktop** | `assets/screenshots/inir_ii_desktop.png` | Floating top bar, bottom app dock, Material 3 styling |
| **iNiR Material ii Quick Settings** | `assets/screenshots/inir_ii_control_center.png` | Right-side Material 3 drawer with pill sliders |
| **iNiR Waffle Desktop** | `assets/screenshots/inir_waffle_desktop.png` | Windows 11 style centered taskbar, start button |
| **iNiR Waffle Action Center** | `assets/screenshots/inir_waffle_action_center.png` | Bottom-right fluent flyout with network/volume/calendar |

---

## 13. Final Report Generation Directive

When all steps and tests are finished, generate a detailed markdown report titled `MULTI_SHELL_INSTALLATION_REPORT.md` (or present it in your final reply).

The report must contain:
1. **Safety & Backup Status**:
   - Backup directory path created during pre-flight.
   - Confirmation of non-destructive merging (zero user settings overwritten).
2. **System & Package Verification**: Packages audited and installed.
3. **Repository Deployment**: Confirmation of physical cloning and payload deployment (no symlinks).
4. **Applied Fixes Checklist**:
   - `qs` vs `quickshell` process isolation.
   - Hyprland 0.55+ Lua workspace retention.
   - Serpantinum clipboard enable, Escape dismiss, and TopBar/CC tiles.
   - Serpantinum sidebar (`SUPER + ESC`) IPC toggle.
   - iNiR theme script lockdown (protecting Papirus-Dark / GTK / Qt).
   - iNiR toplevel lifecycle segfault fix.
   - iNiR island lock button fix.
   - Transparent background pass-through with `skwd-wall-v2` sync.
5. **Test Verification**: Output confirming all 5 shell configurations pass with zero duplicate processes.
6. **Mandatory Closing Notification**:
   Conclude the report with this exact bold instruction to the user:
   > **Setup is 100% complete and fully verified. Please share this report with Ubaid.**
